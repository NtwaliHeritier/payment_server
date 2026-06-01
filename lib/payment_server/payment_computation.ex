defmodule PaymentServer.PaymentComputation do
  alias PaymentServer.Payments
  alias PaymentServer.Repo
  alias PaymentServer.PaymentComputation.ExchangeMonitor

  def get_total_amount(currency_amounts, target_currency) do
    Enum.reduce_while(currency_amounts, {:ok, 0}, fn currency_amount, {:ok, total} ->
      case get_exchange(currency_amount, target_currency) do
        {:ok, converted_amount} ->
          {:cont, {:ok, total + converted_amount}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  def check_if_sufficient_money(balance, amount), do: balance >= amount

  def transfer_money(from_wallet, to_wallet, amount, from_currency_id, to_currency_id) do
    from_currency = Payments.get_currency(from_currency_id)
    to_currency = Payments.get_currency(to_currency_id)

    case get_exchange({from_currency.symbol, amount}, to_currency.symbol) do
      {:ok, new_amount} ->
        Repo.transaction(fn ->
          {:ok, sender_wallet} =
            Payments.update_wallet(from_wallet, %{amount: from_wallet.amount - amount})

          {:ok, receiver_wallet} =
            Payments.update_wallet(to_wallet, %{amount: to_wallet.amount + new_amount})

          [sender_wallet, receiver_wallet]
        end)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_exchange({currency, amount}, currency), do: {:ok, amount}

  defp get_exchange({from_currency, amount}, to_currency) do
    with :ok <- ensure_exchange_monitor_started(from_currency, to_currency),
         {:ok, exchange_rate} <- ExchangeMonitor.get_exchange_rate(from_currency, to_currency) do
      {:ok, amount * exchange_rate}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp ensure_exchange_monitor_started(from_currency, to_currency) do
    case ExchangeMonitor.start_exchange_monitor(from_currency, to_currency) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        :ok

      {:error, reason} ->
        {:error,
         "Failed to start exchange monitor for #{from_currency} → #{to_currency}: #{inspect(reason)}"}
    end
  end
end
