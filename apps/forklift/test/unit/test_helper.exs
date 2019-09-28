ExUnit.start(exclude: [:skip])
Faker.start()
Mox.defmock(Forklift.MockReader, for: Pipeline.Reader)

defmodule Helper do
  def make_kafka_message(value, topic) do
    %{
      topic: topic,
      value: value |> Jason.encode!(),
      offset: :rand.uniform(999),
      partition: :rand.uniform(100),
      key: "a key"
    }
  end

  def create_operational_map() do
    %{
      kafka_key: "somevalue",
      forklift_start_time: "1900-01-01",
      timing: [
        %{
          app: "reaper",
          label: "json_decode",
          start_time: "1900-01-01",
          end_time: "1901-01-01"
        }
      ]
    }
  end
end
