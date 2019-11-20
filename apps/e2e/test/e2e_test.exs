defmodule E2ETest do
  use ExUnit.Case
  use Divo
  use Placebo

  @moduletag :e2e
  @moduletag capture_log: false

  alias SmartCity.TestDataGenerator, as: TDG
  import SmartCity.TestHelper

  @brokers Application.get_env(:e2e, :elsa_brokers)
  @overrides %{
    technical: %{
      orgName: "end_to",
      dataName: "end",
      systemName: "end_to__end",
      schema: [
        %{name: "one", type: "boolean"},
        %{name: "two", type: "string"},
        %{name: "three", type: "integer"}
      ],
      sourceType: "ingest",
      sourceFormat: "text/csv",
      cadence: "once"
    }
  }

  setup_all do
    bypass = Bypass.open()
    user = Application.get_env(:andi, :ldap_user)
    pass = Application.get_env(:andi, :ldap_pass)
    Paddle.authenticate(user, pass)
    Paddle.add([ou: "integration"], objectClass: ["top", "organizationalunit"], ou: "integration")

    Bypass.stub(bypass, "GET", "/path/to/the/data.csv", fn conn ->
      IO.inspect(conn, label: "bypass")
      Plug.Conn.resp(conn, 200, "true,foobar,10")
    end)

    dataset =
      @overrides
      |> put_in(
        [:technical, :sourceUrl],
        "http://localhost:#{bypass.port()}/path/to/the/data.csv"
      )
      |> TDG.create_dataset()

    IO.inspect(dataset, label: "Dataset")

    [dataset: dataset]
  end

  describe "creating an organization" do
    test "via RESTful POST" do
      org = TDG.create_organization(%{orgName: "end_to", id: "org-id"})
      IO.inspect(org, label: "Organization")

      resp =
        HTTPoison.post!("http://localhost:4000/api/v1/organization", Jason.encode!(org), [
          {"Content-Type", "application/json"}
        ])

      assert resp.status_code == 201
    end

    test "persists the organization for downstream use" do
      base = Application.get_env(:paddle, Paddle)[:base]

      eventually(fn ->
        with resp <- HTTPoison.get!("http://localhost:4000/api/v1/organizations"),
             [org] <- Jason.decode!(resp.body) do
          assert org["dn"] == "cn=end_to,ou=integration,#{base}"
          assert org["id"] == "org-id"
          assert org["orgName"] == "end_to"
        end
      end)
    end
  end

  describe "creating a dataset" do
    test "via RESTful PUT", %{dataset: ds} do
      resp =
        HTTPoison.put!("http://localhost:4000/api/v1/dataset", Jason.encode!(ds), [
          {"Content-Type", "application/json"}
        ])

      assert resp.status_code == 201
    end

    test "creates a PrestoDB table" do
      expected = [
        %{"Column" => "one", "Comment" => "", "Extra" => "", "Type" => "boolean"},
        %{"Column" => "two", "Comment" => "", "Extra" => "", "Type" => "varchar"},
        %{"Column" => "three", "Comment" => "", "Extra" => "", "Type" => "integer"}
      ]

      eventually(fn ->
        table =
          try do
            query("describe hive.default.end_to__end", true)
          rescue
            _ -> []
          end

        assert table == expected
      end)
    end

    test "stores a definition that can be retrieved", %{dataset: expected} do
      resp = HTTPoison.get!("http://localhost:4000/api/v1/datasets")
      assert resp.body == Jason.encode!([expected])
    end
  end

  # This series of tests should be extended as more apps are added to the umbrella.
  describe "ingested data" do
    test "is written by reaper", %{dataset: ds} do
      topic = "#{Application.get_env(:reaper, :output_topic_prefix)}-#{ds.id}"

      eventually(fn ->
        {:ok, _, [message]} = Elsa.fetch(@brokers, topic)
        {:ok, data} = SmartCity.Data.new(message.value)

        assert %{"one" => "true", "two" => "foobar", "three" => "10"} == data.payload
      end)
    end

    test "is standardized by valkyrie", %{dataset: ds} do
      topic = "#{Application.get_env(:valkyrie, :output_topic_prefix)}-#{ds.id}"

      eventually(fn ->
        {:ok, _, [message]} = Elsa.fetch(@brokers, topic)
        {:ok, data} = SmartCity.Data.new(message.value)

        assert %{"one" => true, "two" => "foobar", "three" => 10} == data.payload
      end)
    end

    @tag timeout: :infinity
    test "persists in PrestoDB", %{dataset: ds} do
      Process.sleep(30_000)
      topic = "#{Application.get_env(:forklift, :input_topic_prefix)}-#{ds.id}"
      table = ds.technical.systemName

      eventually(fn ->
        assert Elsa.topic?(@brokers, topic)
      end)

      eventually(
        fn ->
          assert [[true, "foobar", 10]] = query("select * from #{table}")
        end,
        10_000
      )
    end

    test "is profiled by flair", %{dataset: ds} do
      table = Application.get_env(:flair, :table_name_timing)

      expected = ["SmartCityOS", "forklift", "valkyrie", "reaper"]
      actual = query("select distinct dataset_id, app from #{table}")

      Enum.each(expected, fn app -> assert [ds.id, app] in actual end)
    end
  end

  def query(statement, toggle \\ false) do
    statement
    |> Prestige.execute(rows_as_maps: toggle)
    |> Prestige.prefetch()
  end
end
