use Mix.Config

config :pipeline,
  elsa_brokers: [{:localhost, 9092}],
  output_topic: "output-topic",
  producer_name: :"integration-producer",
  divo: [{DivoKafka, [outside_host: "localhost"]}, Pipeline.DivoPresto],
  divo_wait: [dwell: 700, max_tries: 50]

config :prestige,
  base_url: "http://localhost:8080",
  headers: [
    catalog: "hive",
    schema: "default",
    user: "foobar"
  ]

defmodule Pipeline.DivoPresto do
  @moduledoc """
  Defines a presto stack compatible with divo
  for building a docker-compose file.
  """

  def gen_stack(_envar) do
    %{
      metastore: %{
        image: "smartcitiesdata/metastore-testo:0.9.12",
        depends_on: ["postgres"],
        ports: ["9083:9083"],
        command:
          ~s(/bin/bash -c "/opt/hive-metastore/bin/schematool -dbType postgres -validate || /opt/hive-metastore/bin/schematool -dbType postgres -initSchema;
          /opt/hive-metastore/bin/start-metastore")
      },
      postgres: %{
        logging: %{driver: "none"},
        image: "smartcitiesdata/postgres-testo:0.9.12",
        ports: ["5432:5432"]
      },
      minio: %{
        image: "smartcitiesdata/minio-testo:0.9.12",
        ports: ["9000:9000"]
      },
      presto: %{
        depends_on: ["metastore", "minio"],
        image: "smartcitiesdata/presto-testo:0.9.12",
        ports: ["8080:8080"],
        healthcheck: %{
          test: [
            "CMD-SHELL",
            ~s(curl -s http://localhost:8080/v1/info | grep -q '"starting":false')
          ],
          interval: "10s",
          timeout: "60s",
          retries: 20
        }
      }
    }
  end
end
