defmodule PaymentServer.Payments do
  alias PaymentServer.Repo
  alias PaymentServer.Payments.{Wallet, Currency}

  def create_wallet(params) do
    %Wallet{}
    |> Wallet.changeset(params)
    |> Repo.insert()
  end

  def all_Wallets_by_user_id(user_id) do
    Wallet.query_by_user_id(user_id)
    |> Repo.all
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
    |> Repo.all()
  end

  def update_wallet(wallet, params) do
    wallet
    |> Wallet.changeset(params)
    |> Repo.update()
  end

  def create_currency(params) do
    %Currency{}
    |> Currency.changeset(params)
    |> Repo.insert()
  end

  def get_currency(currency_id), do: Repo.get(Currency, currency_id)
end
