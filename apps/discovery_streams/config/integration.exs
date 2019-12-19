use Mix.Config

host = "127.0.0.1"
endpoints = [{String.to_atom(host), 9092}]

config :discovery_streams,
  divo: [
    {DivoKafka, [create_topics: "event-stream:1:1", outside_host: host]},
    {DivoRedis, []}
  ],
  divo_wait: [dwell: 700, max_tries: 50]

config :kaffe,
  consumer: [
    endpoints: endpoints,
    topics: [],
    consumer_group: "discovery-streams",
    message_handler: DiscoveryStreams.MessageHandler,
    offset_reset_policy: :reset_to_latest
  ]

config :discovery_streams, topic_subscriber_interval: 1_000

config :discovery_streams, :brook,
  instance: :discovery_streams,
  driver: [
    module: Brook.Driver.Kafka,
    init_arg: [
      endpoints: endpoints,
      topic: "event-stream",
      group: "discovery_streams-events",
      consumer_config: [
        begin_offset: :earliest
      ]
    ]
  ],
  handlers: [DiscoveryStreams.EventHandler],
  storage: [
    module: Brook.Storage.Redis,
    init_arg: [
      redix_args: [host: host],
      namespace: "discovery_streams:view"
    ]
  ]

config :phoenix, serve_endpoints: true
