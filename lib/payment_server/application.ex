defmodule PaymentServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      PaymentServer.Repo,
      # Start the Telemetry supervisor
      PaymentServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PaymentServer.PubSub},
      # Start the Endpoint (http/https)
      PaymentServerWeb.Endpoint,
      PaymentServer.PaymentComputation.ExchangeSupervisor,
      {Absinthe.Subscription, [PaymentServerWeb.Endpoint]}
      # Start a worker by calling: PaymentServer.Worker.start_link(arg)
      # {PaymentServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PaymentServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PaymentServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
