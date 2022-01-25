# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :payment_server,
  ecto_repos: [PaymentServer.Repo]

config :payment_server,
  symbols: ["CAD", "USD", "EUR"]

config :ecto_shorts,
  repo: PaymentServer.Repo,
  error_module: EctoShorts.Actions.Error

# Configures the endpoint
config :payment_server, PaymentServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SMSjWb9pDjBXCpBQCBn0hPLOnSmw//LyU81WhrGftPXDUd/5POYdYU951iSwL4YJ",
  render_errors: [view: PaymentServerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: PaymentServer.PubSub,
  live_view: [signing_salt: "57lsdx6O"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
