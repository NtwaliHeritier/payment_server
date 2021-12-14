defmodule PaymentServer.PaymentComputation.ExchangeMonitor do
  use GenServer
  alias PaymentServer.Exchange.PaymentSource

  def start_link({from, to} = state) do
    name = name(from, to)
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def get_exchange_rate(name) do
    GenServer.call(name, :exchange_rate)
  end

  def init({from, to}) do
    exchange_rate = get_latest_exchange_rate(from, to)
    state = %{from: from, to: to, exchange_rate: exchange_rate}
    {:ok, state}
  end

  def handle_info(:refresh, %{from: from, to: to} = state) do
    propagate_changes(state)
    exchange_rate = get_latest_exchange_rate(from, to)
    {:noreply, %{state | exchange_rate: exchange_rate}}
  end

  def handle_call(:exchange_rate, _, state) do
    {:reply, state[:exchange_rate], state}
  end

  defp get_latest_exchange_rate(from, to) do
    exchange_rate = PaymentSource.fetch_exchange_rate(from, to)
    Process.send_after(self(), :refresh, :timer.seconds(1))
    exchange_rate
  end

  defp name(from, to), do: :"#{from}/#{to}"

  defp propagate_changes(state) do
    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      state,
      subscribe_exchange_rate_change: "rate_update#{state.from}/#{state.to}"
    )
    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      state,
      subscribe_all_exchange_rate_change: "exchange_rate_update"
    )
  end
end
