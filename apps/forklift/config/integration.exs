use Mix.Config

host =
  case System.get_env("HOST_IP") do
    nil -> "127.0.0.1"
    defined -> defined
  end

endpoint = [{to_charlist(host), 9094}]

config :forklift,
  message_processing_cadence: 10_000

config :kaffe,
  producer: [
    endpoints: endpoint,
    topics: ["streaming-transformed", "dataset-registry"],
    max_retries: 30,
    retry_backoff_ms: 500
  ],
  consumer: [
    endpoints: endpoint
  ]

config :prestige,
  base_url: "http://#{host}:8080",
  headers: [
    catalog: "hive",
    schema: "default",
    user: "foobar"
  ]

config(:forklift, divo: "docker-compose.yml", divo_wait: [dwell: 1000, max_tries: 50])

config :redix,
  host: host
