defmodule PaymentServer.PaymentComputation.PaymentCalculation do
  alias PaymentServer.Payments
  alias PaymentServer.PaymentComputation.ExchangeMonitor

  def get_total_amount(currency_amount, currency) do
    currency_amount
    |> Enum.map(&get_exchange(&1, currency))
    |> Enum.sum()
  end

  def check_if_sufficient_money(balance, amount), do: balance >= amount

  def transfer_money(from_wallet, to_wallet, amount, from_currency, to_currency) do
    new_amount = get_exchanged_amount(from_currency, to_currency, amount)
    {:ok, sender_wallet} = Payments.update_wallet(from_wallet, %{amount: from_wallet.amount - amount})
    {:ok, receiver_wallet} = Payments.update_wallet(to_wallet, %{amount: to_wallet.amount + new_amount})
    [sender_wallet, receiver_wallet]
  end

  defp get_exchange({currency, amount}, currency), do: amount

  defp get_exchange({from_currency, amount}, to_currency) do
    exchange_rate = ExchangeMonitor.get_exchange_rate(:"#{from_currency}/#{to_currency}") |> String.to_float()
    amount * exchange_rate
  end

  defp get_exchanged_amount(from_currency, to_currency, amount) do
    case from_currency === to_currency do
      true -> amount
      false -> get_exchange({from_currency, amount}, to_currency)
    end
  end
end
