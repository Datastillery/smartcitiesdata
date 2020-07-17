use Mix.Config

config :discovery_streams, DiscoveryStreamsWeb.Endpoint,
  http: [port: 4001, stream_handlers: [Web.StreamHandlers.StripServerHeader, :cowboy_stream_h]],
  secret_key_base: "This is a test key",
  render_errors: [view: DiscoveryStreamsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DiscoveryStreams.PubSub, adapter: Phoenix.PubSub.PG2],
  instrumenters: [DiscoveryStreamsWeb.Endpoint.Instrumenter]

# https://github.com/deadtrickster/prometheus-phoenix/issues/11
config :prometheus, DiscoveryStreamsWeb.Endpoint.Instrumenter,
  controller_call_labels: [:controller, :action],
  channel_join_labels: [:channel, :topic, :transport],
  channel_receive_labels: [:channel, :topic, :transport]

config :logger,
  backends: [:console],
  level: :debug,
  compile_time_purge_level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :discovery_streams,
  ttl: 600_000,
  topic_prefix: "transformed-",
  metrics_port: 9004,
  topic_subscriber_config: [
    begin_offset: :earliest,
    offset_reset_policy: :reset_to_earliest,
    max_bytes: 1_000_000,
    min_bytes: 0,
    max_wait_time: 10_000,
    prefetch_count: 0,
    prefetch_bytes: 1_000_000
  ]

config :ex_aws,
  region: "us-east-2"

config :streaming_metrics,
  collector: StreamingMetrics.ConsoleMetricCollector

import_config "#{Mix.env()}.exs"
