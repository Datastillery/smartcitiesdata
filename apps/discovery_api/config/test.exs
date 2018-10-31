use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :discovery_api, DiscoveryApiWeb.Endpoint,
  http: [port: 4001],
  server: false


config :discovery_api,
  test_mode: true

# Print only warnings and errors during test
config :logger, level: :info
