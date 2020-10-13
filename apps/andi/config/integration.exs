use Mix.Config

host =
  case System.get_env("HOST_IP") do
    nil -> "localhost"
    defined -> defined
  end

redix_args = [host: host]
endpoint = [{host, 9092}]

db_name = "andi_test"
db_username = "postgres"
db_password = "postgres"
db_port = "5456"

config :andi,
  divo: [
    {DivoKafka, [create_topics: "event-stream:1:1", outside_host: host, kafka_image_version: "2.12-2.1.1"]},
    {DivoRedis, []},
    {
      DivoPostgres, [
        user: db_username,
        database: db_name,
        port: db_port
      ]
    }
  ],
  divo_wait: [dwell: 700, max_tries: 50],
  kafka_broker: endpoint,
  dead_letter_topic: "dead-letters",
  kafka_endpoints: endpoint,
  hsts_enabled: false

config :andi, Andi.Repo,
  database: db_name,
  username: db_username,
  password: db_password,
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  port: db_port

config :andi, AndiWeb.Endpoint,
  http: [port: 4000],
  server: true,
  check_origin: false

# for auth0 login use, add to Endpoint config above
# https: [
#   port: 4443,
#   otp_app: :andi,
#   keyfile: "priv/key.pem",
#   certfile: "priv/cert.pem"
# ]

config :andi, :brook,
  instance: :andi,
  driver: [
    module: Brook.Driver.Kafka,
    init_arg: [
      endpoints: endpoint,
      topic: "event-stream",
      group: "andi-event-stream",
      consumer_config: [
        begin_offset: :earliest,
        offset_reset_policy: :reset_to_earliest
      ]
    ]
  ],
  handlers: [Andi.Event.EventHandler],
  storage: [
    module: Brook.Storage.Redis,
    init_arg: [redix_args: redix_args, namespace: "andi:view"]
  ]

config :andi, AndiWeb.Endpoint,
  pubsub: [name: AndiWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  code_reloader: true,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ],
  reloadable_apps: [:andi],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/andi_web/controllers/.*(ex)$},
      ~r{lib/andi_web/live/.*(ex)$},
      ~r{lib/andi_web/views/.*(ex)$},
      ~r{lib/andi_web/templates/.*(eex)$}
    ]
  ],
  live_view: [
    signing_salt: "SUPER VERY TOP SECRET!!!"
  ]

config :ueberauth, Ueberauth,
  providers: [
    auth0:
      {Ueberauth.Strategy.Auth0,
       [
         default_audience: "andi",
         allowed_request_params: [
           :scope,
           :state,
           :audience,
           :connection,
           :prompt,
           :screen_hint,
           :login_hint,
           :error_message
         ]
       ]}
  ]

config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: "smartcolumbusos-demo.auth0.com",
  client_id: "KrA99qgUDwRWvbI07YOknIZSS1jzdXUr",
  client_secret: System.get_env("AUTH0_CLIENT_SECRET")

config :andi, AndiWeb.Auth.TokenHandler,
  issuer: "https://smartcolumbusos-demo.auth0.com/",
  allowed_algos: ["RS256"],
  verify_issuer: false,
  allowed_drift: 3_000_000_000_000

config :guardian, Guardian.DB, repo: Andi.Repo
