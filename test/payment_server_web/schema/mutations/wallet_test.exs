defmodule PaymentServerWeb.Schema.Mutations.WalletTest do
  use PaymentServer.DataCase

  alias PaymentServerWeb.Schema

  import PaymentServerWeb.Support.AccountsPayments, only: [create_user: 1, create_currency: 1, create_wallets: 1]

  @create_wallets """
    mutation createWallets($amount: Integer!, $userId: Integer!, $currencyId: Integer!) {
      createWallets(amount: $amount, userId: $userId, currencyId: $currencyId) {
        amount
      }
    }
  """

  describe "@create_wallets" do
    setup [:create_user, :create_currency]

    test "creates a new wallet", %{user: user, currency: currency} do
      assert {:ok, %{data: data}} = Absinthe.run(@create_wallets, Schema, variables: %{"userId" => user.id, "amount" => 100, "currencyId" => currency.id})
      assert data["createWallets"]["amount"] === "100.0"
    end
  end

  @send_money """
    mutation sendMoney($amount: Float!, $from: Integer!, $to: Integer!, $fromCurrencyId: Integer!, $toCurrencyId: Int) {
      sendMoney(amount: $amount, from: $from, to: $to, fromCurrencyId: $fromCurrencyId, toCurrencyId: $toCurrencyId) {
        amount
      }
    }
  """

  describe "@send_money" do
    setup [:create_wallets]

    test "sends money from one wallet to another", %{user1: user1, user2: user2, currency: currency} do
      assert {:ok, %{data: data}} = Absinthe.run(@send_money, Schema, variables:
        %{"amount" => 20, "from" => user1.id, "to" => user2.id, "fromCurrencyId" => currency.id})
      assert data["sendMoney"] |> length === 2
      assert data["sendMoney"] === [%{"amount" => "180.0"}, %{"amount" => "120.0"}]
    end
  end
end
