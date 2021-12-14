defmodule PaymentServerWeb.Resolvers.WalletResolver do
  alias PaymentServer.Payments
  alias PaymentServer.PaymentComputation.PaymentCalculation
  alias PaymentServer.Payments.Wallet

  def all_wallets_by_user_id(%{user_id: user_id}, _) do
    # {:ok, Payments.all_Wallets_by_user_id(user_id)}
    case Payments.all_Wallets_by_user_id(user_id) do
      [] -> {:error, message: "No wallet found", details: "There is no wallet found for the provided input"}
      wallet -> {:ok, wallet}
    end
  end

  def user_wallets_by_currency(%{currency_id: currency_id, user_id: user_id}, _) do
    case Payments.user_wallets_by_currency(user_id, currency_id) do
      nil -> {:error, message: "No wallet found", details: "There is no wallet found for the provided input"}
      wallet -> {:ok, wallet}
    end
  end

  def user_total_worth(%{currency_id: currency_id, user_id: user_id}, _) do
    case Payments.total_amount(user_id) do
      [] -> {:error, message: "No data found", details: "No data with provided input found"}
      currency_amount ->
        currency = Payments.get_currency(currency_id)
        {:ok, PaymentCalculation.get_total_amount(currency_amount, currency.symbol)}
    end
  end

  def create_wallet(params, _) do
    case Payments.create_wallet(params) do
      {:ok, wallet} ->
        {:ok, wallet}
        {:error, _} ->
          {:error, message: "Could not create wallet", details: "New wallet could not be created"}
    end
  end

  def send_money(%{amount: amount, from: from, to: to, from_currency_id: from_currency_id} = params, _) do
    to_currency_id = Map.get(params, :to_currency_id, from_currency_id)
    with %Wallet{} = from_wallet <- Payments.user_wallets_by_currency(from, from_currency_id),
          true <- PaymentCalculation.check_if_sufficient_money(from_wallet.amount, amount),
          %Wallet{} = to_wallet <- Payments.user_wallets_by_currency(to, to_currency_id)
    do
      from_currency = Payments.get_currency(from_currency_id)
      to_currency = Payments.get_currency(to_currency_id)
      {:ok, PaymentCalculation.transfer_money(from_wallet, to_wallet, amount, from_currency.symbol, to_currency.symbol)}
    else
    _ -> {:error, message: "Transaction failed", details: "Could not send money"}
    end
  end
end
