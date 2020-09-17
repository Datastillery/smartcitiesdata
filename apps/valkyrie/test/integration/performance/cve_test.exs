defmodule Valkyrie.Performance.CveTest do
  use ExUnit.Case
  use Divo
  use Retry
  require Logger

  import Valkyrie.Application
  alias SmartCity.TestDataGenerator, as: TDG
  import SmartCity.Event, only: [data_ingest_start: 0]
  import SmartCity.TestHelper

  @moduletag :performance

  @endpoints Application.get_env(:valkyrie, :elsa_brokers)
  @input_topic_prefix Application.get_env(:valkyrie, :input_topic_prefix)
  @output_topic_prefix Application.get_env(:valkyrie, :output_topic_prefix)

  @messages %{
    map: File.read!(File.cwd!() <> "/test/integration/performance/map_message.json") |> Jason.decode!(),
    spat: File.read!(File.cwd!() <> "/test/integration/performance/spat_message.json") |> Jason.decode!(),
    bsm: File.read!(File.cwd!() <> "/test/integration/performance/bsm_message.json") |> Jason.decode!()
  }

  defmodule SetupConfig do
    defstruct [:messages, prefetch_count: 0, prefetch_bytes: 1_000_000, max_bytes: 1_000_000, max_wait_time: 10_000]
  end

  setup_all do
    Logger.configure(level: :warn)
    Agent.start(fn -> 0 end, name: :counter)

    :ok
  end

  @tag timeout: :infinity
  test "run performance test" do
    map_messages = generate_messages(1_000, :map)
    spat_messages = generate_messages(10_000, :spat)
    bsm_messages = generate_messages(10_000, :bsm)

    Benchee.run(
      %{
        "kafka" => fn {dataset, expected_count, input_topic, output_topic} = _output_from_before_each ->
          Brook.Event.send(instance(), data_ingest_start(), :author, dataset)

          eventually(
            fn ->
              current_total = get_total_messages(output_topic)

              assert current_total >= expected_count
            end,
            100,
            5000
          )

          {dataset, input_topic, output_topic}
        end
      },
      inputs: %{
        "map" => %SetupConfig{messages: map_messages},
        "spat" => %SetupConfig{messages: spat_messages},
        "bsm" => %SetupConfig{messages: bsm_messages}
      },
      before_scenario: fn %SetupConfig{
                            messages: messages,
                            prefetch_count: prefetch_count,
                            prefetch_bytes: prefetch_bytes,
                            max_bytes: max_bytes,
                            max_wait_time: max_wait_time
                          } = _parameters_from_inputs ->
        existing_topic_config = Application.get_env(:valkyrie, :topic_subscriber_config)

        updated_topic_config =
          Keyword.merge(
            existing_topic_config,
            prefetch_count: prefetch_count,
            prefetch_bytes: prefetch_bytes,
            max_bytes: max_bytes,
            max_wait_time: max_wait_time
          )

        Application.put_env(:valkyrie, :topic_subscriber_config, updated_topic_config)

        messages
      end,
      before_each: fn {messages, count} = _output_from_before_scenario ->
        dataset = create_cve_dataset()

        iteration = Agent.get_and_update(:counter, fn s -> {s, s + 1} end)
        Logger.debug("Iteration #{iteration} for dataset #{dataset.id}")

        {input_topic, output_topic} = setup_topics(dataset)
        load_messages(dataset, input_topic, messages, count, 10_000)

        {dataset, count, input_topic, output_topic}
      end,
      after_each: fn {dataset, input_topic, output_topic} = _output_from_run ->
        Valkyrie.DatasetProcessor.stop(dataset.id)

        Elsa.delete_topic(@endpoints, input_topic)
        Elsa.delete_topic(@endpoints, output_topic)
      end,
      time: 30,
      memory_time: 0.5,
      warmup: 0
    )
  end

  defp generate_messages(count, type) do
    temporary_dataset = create_cve_dataset()

    messages =
      1..count
      |> Enum.map(fn _ -> create_data_message(temporary_dataset, type) end)

    Logger.debug("Generated #{length(messages)} MAP messages")
    {messages, count}
  end

  defp setup_topics(dataset) do
    input_topic = "#{@input_topic_prefix}-#{dataset.id}"
    output_topic = "#{@output_topic_prefix}-#{dataset.id}"

    Logger.debug("Setting up #{input_topic} => #{output_topic} for #{dataset.id}")
    Elsa.create_topic(@endpoints, input_topic)
    Elsa.create_topic(@endpoints, output_topic)
    wait_for_topic!(input_topic)
    wait_for_topic!(output_topic)

    {input_topic, output_topic}
  end

  defp load_messages(dataset, topic, messages, expected_count, producer_chunk_size) do
    num_producers = div(expected_count, producer_chunk_size)
    producer_name = :"#{topic}_producer"

    Logger.debug("Loading #{expected_count} messages into kafka with #{num_producers} producers")

    {:ok, producer_pid} =
      Elsa.Supervisor.start_link(endpoints: @endpoints, producer: [topic: topic], connection: producer_name)

    Elsa.Producer.ready?(producer_name)

    messages
    |> Stream.map(&prepare_messages(&1, dataset))
    |> Stream.chunk_every(producer_chunk_size)
    |> Enum.map(&spawn_producer_chunk(&1, topic, producer_name))
    |> Enum.each(&Task.await(&1, :infinity))

    eventually(
      fn ->
        current_total = get_total_messages(topic, 1)

        assert current_total >= expected_count
      end,
      200,
      5000
    )

    Process.exit(producer_pid, :normal)

    Logger.debug("Done loading #{expected_count} messages")
  end

  defp prepare_messages({key, message}, dataset) do
    json =
      message
      |> Map.put(:dataset_id, dataset.id)
      |> Jason.encode!()

    {key, json}
  end

  defp spawn_producer_chunk(chunk, topic, producer_name) do
    Task.async(fn ->
      chunk
      |> Stream.chunk_every(1000)
      |> Enum.each(fn load_chunk ->
        Elsa.produce(producer_name, topic, load_chunk, partition: 0)
      end)
    end)
  end

  defp get_total_messages(topic, num_partitions \\ 1) do
    0..(num_partitions - 1)
    |> Enum.map(fn partition -> :brod.resolve_offset(@endpoints, topic, partition) end)
    |> Enum.map(fn {:ok, value} -> value end)
    |> Enum.sum()
  end

  defp create_cve_dataset() do
    schema = [
      %{type: "string", name: "timestamp"},
      %{type: "string", name: "messageType"},
      %{type: "json", name: "messageBody"},
      %{type: "string", name: "sourceDevice"}
    ]

    TDG.create_dataset(technical: %{schema: schema})
  end

  defp create_data_message(dataset, type) do
    payload = %{
      timestamp: DateTime.utc_now(),
      messageType: String.upcase(to_string(type)),
      messageBody: @messages[type],
      sourceDevice: "yidontknow"
    }

    data = TDG.create_data(dataset_id: dataset.id, payload: payload)
    {"", data}
  end

  defp wait_for_topic!(topic) do
    wait exponential_backoff(100) |> Stream.take(10) do
      Elsa.topic?(@endpoints, topic)
    after
      _ -> topic
    else
      _ -> raise "Timed out waiting for #{topic} to be available"
    end
  end
end
