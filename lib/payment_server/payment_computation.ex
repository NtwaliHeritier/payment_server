defmodule PaymentServer.PaymentComputation do
  alias PaymentServer.Payments
  alias PaymentServer.Repo
  alias PaymentServer.PaymentComputation.ExchangeMonitor
  alias PaymentServer.Payments.Transfer

  def get_total_amount(currency_amounts, target_currency) do
    Enum.reduce_while(currency_amounts, {:ok, 0}, fn currency_amount, {:ok, total} ->
      case get_exchange_and_amount(currency_amount, target_currency) do
        {:ok, converted_amount, _} ->
          {:cont, {:ok, total + converted_amount}}

        {:error, reason, _} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  def check_if_sufficient_money(balance, amount), do: balance >= amount

  def transfer_money(
        idempotency_key,
        from_wallet,
        to_wallet,
        amount,
        from_currency_id,
        to_currency_id
      ) do
    from_currency = Payments.get_currency(from_currency_id)
    to_currency = Payments.get_currency(to_currency_id)

    case get_exchange_and_amount({from_currency.symbol, amount}, to_currency.symbol) do
      {:ok, new_amount, exchange_rate} ->
        # exchange_rate = Decimal.div(new_amount, amount)

        Repo.transaction(fn ->
          case Repo.get_by(Transfer,
                 from_wallet_id: from_wallet.id,
                 idempotency_key: idempotency_key
               ) do
            nil ->
              Repo.insert!(%Transfer{
                idempotency_key: idempotency_key,
                from_wallet_id: from_wallet.id,
                to_wallet_id: to_wallet.id,
                amount_sent: amount,
                amount_received: new_amount,
                exchange_rate: exchange_rate
              })

              {:ok, sender_wallet} =
                Payments.update_wallet(from_wallet, %{amount: from_wallet.amount - amount})

              {:ok, receiver_wallet} =
                Payments.update_wallet(to_wallet, %{amount: to_wallet.amount + new_amount})

              [sender_wallet, receiver_wallet]

            existing ->
              Repo.rollback({:already_processed, existing})
          end
        end)

      {:error, reason, _} ->
        {:error, reason}
    end
  end

  defp get_exchange_and_amount({currency, amount}, currency), do: {:ok, amount, 1}

  defp get_exchange_and_amount({from_currency, amount}, to_currency) do
    with :ok <- ensure_exchange_monitor_started(from_currency, to_currency),
         {:ok, exchange_rate} <- ExchangeMonitor.get_exchange_rate(from_currency, to_currency) do
      {:ok, amount * exchange_rate, exchange_rate}
    else
      {:error, reason} ->
        {:error, reason, nil}
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
