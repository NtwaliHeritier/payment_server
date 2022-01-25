use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :payment_server, PaymentServer.Repo,
  username: "hatsor",
  password: "hatsor",
  database: "payment_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :payment_server, PaymentServerWeb.Endpoint,
  http: [port: 4002],
  server: false

  config :payment_server, source: PaymentServerWeb.Support.PaymentFake
# Print only warnings and errors during test
config :logger, level: :warn
