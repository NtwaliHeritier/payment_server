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

  def start_exchange_monitor(from, to) do
    DynamicSupervisor.start_child(
      PaymentServer.ExchangeMonitorSupervisor,
      {__MODULE__, {from, to}}
    )
  end

  # callbacks

  def init({from, to}) do
    state = %{
      from: from,
      to: to,
      exchange_rate: nil,
      pending_ref: nil,
      fetch_start_time: nil,
      currency_pair: "#{from}/#{to}"
    }

    {:ok, state, {:continue, :initialize_exchange}}
  end

  def handle_continue(:initialize_exchange, %{from: from, to: to} = state) do
    start_time = System.monotonic_time()

    state =
      case Exchange.fetch_exchange_rate(from, to) do
        {:ok, exchange_rate} ->
          :telemetry.execute(
            [:payment_server, :exchange_rate, :fetch, :stop],
            %{duration: System.monotonic_time() - start_time},
            %{currency_pair: state.currency_pair, result: :ok, source: :initial}
          )

          %{state | exchange_rate: exchange_rate}

        {:error, reason} ->
          :telemetry.execute(
            [:payment_server, :exchange_rate, :fetch, :stop],
            %{duration: System.monotonic_time() - start_time},
            %{currency_pair: state.currency_pair, result: :error, source: :initial}
          )

          Logger.error("Initial exchange rate fetch failed for #{from}/#{to}: #{inspect(reason)}")
          state
      end

    # Process.send_after(self(), :refresh, :timer.seconds(1))
    :timer.send_interval(5000, :refresh)
    :timer.send_interval(5000, :report_queue_length)
    {:noreply, state}
  end

  def handle_call(:exchange_rate, _, state) do
    case state.exchange_rate do
      nil -> {:reply, {:error, :exchange_rate_not_available}, state}
      exchange_rate -> {:reply, {:ok, exchange_rate}, state}
    end
  end

  def handle_info(:refresh, %{pending_ref: ref} = state) when not is_nil(ref) do
    {:noreply, state}
  end

  def handle_info(:refresh, %{from: from, to: to} = state) do
    %{ref: ref} =
      Task.Supervisor.async_nolink(PaymentServer.TaskSupervisor, fn ->
        case Exchange.fetch_exchange_rate(from, to) do
          {:ok, exchange_rate} -> {:set_exchange, exchange_rate}
          {:error, reason} -> {:fetch_failed, reason}
        end
      end)

    {:noreply, %{state | pending_ref: ref, fetch_start_time: System.monotonic_time()}}
  end

  def handle_info({ref, {:set_exchange, exchange_rate}}, %{pending_ref: ref} = state) do
    Process.demonitor(ref, [:flush])

    duration = System.monotonic_time() - state.fetch_start_time

    :telemetry.execute(
      [:payment_server, :exchange_rate, :fetch, :stop],
      %{duration: duration},
      %{currency_pair: state.currency_pair, result: :ok}
    )

    state = %{state | exchange_rate: exchange_rate, pending_ref: nil, fetch_start_time: nil}
    propagate_changes(state)

    {:noreply, state}
  end

  def handle_info({ref, {:fetch_failed, reason}}, %{pending_ref: ref} = state) do
    Process.demonitor(ref, [:flush])

    duration = System.monotonic_time() - state.fetch_start_time

    :telemetry.execute(
      [:payment_server, :exchange_rate, :fetch, :stop],
      %{duration: duration},
      %{currency_pair: state.currency_pair, result: :error}
    )

    Logger.error("Exchange rate fetch failed for #{state.from}/#{state.to}: #{inspect(reason)}")
    {:noreply, %{state | pending_ref: nil, fetch_start_time: nil}}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, %{pending_ref: ref} = state)
      when reason != :normal do
    duration = System.monotonic_time() - state.fetch_start_time
    Logger.error("Unexpected crash for #{state.from}/#{state.to}: #{inspect(reason)}")

    :telemetry.execute(
      [:payment_server, :exchange_rate, :fetch, :stop],
      %{duration: duration},
      %{currency_pair: state.currency_pair, result: :crash}
    )

    {:noreply, %{state | pending_ref: nil, fetch_start_time: nil}}
  end

  def handle_info(:report_queue_length, state) do
    {:message_queue_len, len} = Process.info(self(), :message_queue_len)

    :telemetry.execute(
      [:payment_server, :exchange_monitor, :queue_length],
      %{size: len},
      %{node: node(), currency_pair: state.currency_pair}
    )

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp name(from, to), do: {:via, Registry, {PaymentServer.ExchangeRegistry, "#{from}/#{to}"}}

  defp propagate_changes(state) do
    payload = %{
      from: state.from,
      to: state.to,
      exchange_rate: state.exchange_rate
    }

    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      payload,
      subscribe_exchange_rate_change: "rate_update: #{state.from}/#{state.to}"
    )

    Absinthe.Subscription.publish(
      PaymentServerWeb.Endpoint,
      payload,
      subscribe_all_exchange_rate_change: "exchange_rate_update"
    )
  end
end
