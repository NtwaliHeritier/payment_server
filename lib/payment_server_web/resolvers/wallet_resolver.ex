defmodule PaymentServerWeb.Resolvers.WalletResolver do
  alias PaymentServer.Payments
  alias PaymentServer.PaymentComputation
  alias PaymentServer.Payments.Wallet

  def all_wallets_by_user_id(%{user_id: _user_id} = params, _) do
    case Payments.all_wallets_by_user_id(params) do
      [] ->
        {:error,
         message: "No wallet found", details: "There is no wallet found for the provided input"}

      wallet ->
        {:ok, wallet}
    end
  end

  def user_wallets_by_currency(%{currency_id: currency_id, user_id: user_id}, _) do
    case Payments.user_wallets_by_currency(user_id, currency_id) do
      nil ->
        {:error,
         message: "No wallet found", details: "There is no wallet found for the provided input"}

      wallet ->
        {:ok, wallet}
    end
  end

  def user_total_worth(%{currency_id: currency_id, user_id: user_id}, _) do
    with [_ | _] = currency_amount <- Payments.total_amount(user_id),
         {:ok, total} <-
           PaymentComputation.get_total_amount(
             currency_amount,
             Payments.get_currency(currency_id).symbol
           ) do
      {:ok, total}
    else
      [] -> {:error, message: "No data found", details: "No data with provided input found"}
      {:error, reason} -> {:error, message: reason, details: "Exchange rate not available"}
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

  def send_money(
        %{
          idempotency_key: idempotency_key,
          amount: amount,
          from: from,
          to: to,
          from_currency_id: from_currency_id
        } = params,
        _
      ) do
    to_currency_id = Map.get(params, :to_currency_id, from_currency_id)
    transfer_start_time = System.monotonic_time()

    result = do_transfer(idempotency_key, from, to, amount, from_currency_id, to_currency_id)

    :telemetry.execute(
      [:payment_server, :transfer, :stop],
      %{duration: System.monotonic_time() - transfer_start_time, amount: amount},
      %{currency_pair: "#{from_currency_id}/#{to_currency_id}", result: elem(result, 0)}
    )

    result
  end

  defp do_transfer(idempotency_key, from, to, amount, from_currency_id, to_currency_id) do
    with %Wallet{} = from_wallet <- Payments.user_wallets_by_currency(from, from_currency_id),
         true <- PaymentComputation.check_if_sufficient_money(from_wallet.amount, amount),
         %Wallet{} = to_wallet <- Payments.user_wallets_by_currency(to, to_currency_id),
         {:ok, accounts} <-
           PaymentComputation.transfer_money(
             idempotency_key,
             from_wallet,
             to_wallet,
             amount,
             from_currency_id,
             to_currency_id
           ) do
      {:ok, accounts}
    else
      nil -> {:error, message: "Wallet not found"}
      false -> {:error, message: "Insufficient funds"}
      {:error, reason} -> {:error, message: "Transaction failed", details: reason}
    end
  end
end
