use Mix.Config

config :odo,
  working_dir: "/tmp",
  retry_delay: 50,
  retry_backoff: 2

config :odo, :brook,
  handlers: [Odo.Event.EventHandler, Odo.Support.TestEventHandler],
  storage: [
    module: Brook.Storage.Ets,
    init_arg: []
  ],
  driver: [
    module: Brook.Driver.Default,
    init_arg: []
  ]

config :ex_aws,
  access_key_id: "doesnt-matter",
  secret_access_key: "doesnt-matter"
