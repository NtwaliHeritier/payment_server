defmodule PaymentServer.Payments do
  alias PaymentServer.Repo
  alias PaymentServer.Payments.{Wallet, Currency}
  alias EctoShorts.Actions

  def create_wallet(params) do
    Actions.create(Wallet, params)
  end

  def all_Wallets_by_user_id(params) do
    Actions.all(Wallet, params)
  end

  def user_wallets_by_currency(user_id, currency_id) do
    user_id
    |> Wallet.query_by_user_id()
    |> Wallet.join_currency()
    |> Wallet.get_wallets_by_currency(currency_id)
    |> Repo.one
  end

  def total_amount(user_id) do
    user_id
    |> Wallet.query_by_user_id()
    |> Wallet.join_currency()
    |> Wallet.select_amount_currency()
    |> Actions.all()
  end

  def update_wallet(wallet, params) do
    Actions.update(Wallet, wallet.id, params)
  end

  def create_currency(params) do
    Actions.create(Currency, params)
  end

  def get_currency(currency_id), do:  Actions.get(Currency, currency_id)
end
