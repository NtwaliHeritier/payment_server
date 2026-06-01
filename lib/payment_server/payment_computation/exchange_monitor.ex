defmodule PaymentServer.PaymentComputation.ExchangeMonitor do
  use GenServer
  alias PaymentServer.Exchange

  require Logger

  def start_link({from, to} = state) do
    name = name(from, to)
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def get_exchange_rate(from, to) do
    GenServer.call(name(from, to), :exchange_rate)
  end

  def exists?(from, to) do
    if GenServer.whereis(name(from, to)), do: true, else: false
  end

  def start_exchange_monitor(from, to) do
    DynamicSupervisor.start_child(PaymentServer.ExchangeMonitorSupervisor, {__MODULE__, {from, to}})
  end

  # callbacks

  def init({from, to}) do
    state = %{from: from, to: to, exchange_rate: nil}
    {:ok, state, {:continue, :initialize_exchange}}
  end

  def handle_continue(:initialize_exchange, %{from: from, to: to} = state) do
    exchange_rate = get_latest_exchange_rate(from, to)
    Process.send_after(self(), :refresh, :timer.seconds(1))
    {:noreply, %{state | exchange_rate: exchange_rate}}
  end

  def handle_call(:exchange_rate, _, state) do
    {:reply, state[:exchange_rate], state}
  end

  def handle_info(:refresh, %{from: from, to: to} = state) do
    Task.Supervisor.async_nolink(PaymentServer.TaskSupervisor, fn ->
      exchange_rate = get_latest_exchange_rate(from, to)
      {:set_exchange, exchange_rate}
    end)
    {:noreply, state}
  end

  def handle_info({ref, {:set_exchange, exchange_rate}}, state) when is_reference(ref) do
    Process.demonitor(ref, [:flush])
    state = %{state | exchange_rate: exchange_rate}
    propagate_changes(state)
    Process.send_after(self(), :refresh, :timer.seconds(1))
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    IO.inspect "down normal"
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    Logger.error("Exchange rate fetch failed for #{state.from}/#{state.to}: #{inspect(reason)}")
    Process.send_after(self(), :refresh, :timer.seconds(1))
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp get_latest_exchange_rate(from, to), do: Exchange.fetch_exchange_rate(from, to)

  defp name(from, to), do: {:via, Registry, {PaymentServer.ExchangeRegistry, "#{from}/#{to}"}}

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
