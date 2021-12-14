defmodule PaymentServerWeb.Schema.Mutations.WalletTest do
  use PaymentServer.DataCase

  alias PaymentServerWeb.Schema
  alias PaymentServer.{Accounts, Payments}

  @create_wallets """
    mutation createWallets($amount: Integer!, $userId: Integer!, $currencyId: Integer!) {
      createWallets(amount: $amount, userId: $userId, currencyId: $currencyId) {
        amount
      }
    }
  """

  describe "@create_wallets" do
    test "creates a new wallet" do
      [user, currency] = create_wallet()
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
    test "sends money from one wallet to another" do
      [user1, user2, currency] = create_wallets()
      assert {:ok, %{data: data}} = Absinthe.run(@send_money, Schema, variables:
        %{"amount" => 20, "from" => user1.id, "to" => user2.id, "fromCurrencyId" => currency.id})
      assert data["sendMoney"] |> length === 2
      assert data["sendMoney"] === [%{"amount" => "180.0"}, %{"amount" => "120.0"}]
    end
  end

  defp create_wallet do
    {:ok, user} = Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
    {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
    [user, currency]
  end

  defp create_wallets do
    {:ok, user1} = Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
    {:ok, user2} = Accounts.create_user(%{email: "ishkev@gmail.com", name: "ISHIMWE Kevin"})
    {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
    {:ok, _} = Payments.create_wallet(%{amount: 200, user_id: user1.id, currency_id: currency.id})
    {:ok, _} = Payments.create_wallet(%{amount: 100, user_id: user2.id, currency_id: currency.id})
    [user1, user2, currency]
  end
end
