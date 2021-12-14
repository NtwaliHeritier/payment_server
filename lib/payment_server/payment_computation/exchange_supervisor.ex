defmodule PaymentServer.PaymentComputation.ExchangeSupervisor do
  use Supervisor

  alias PaymentServer.PaymentComputation.ExchangeMonitor

  @exchange_combo [
    {"USD", "EUR"},
    {"USD", "CAD"},
    {"EUR", "USD"},
    {"EUR", "CAD"},
    {"CAD", "USD"},
    {"CAD", "EUR"}
  ]

  def start_link(state \\ :ok) do
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    children = Enum.map(@exchange_combo, &Supervisor.child_spec({ExchangeMonitor, &1}, id: &1))
    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
