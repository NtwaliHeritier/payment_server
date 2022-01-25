defmodule PaymentServerWeb.Schema.Queries.WalletTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema

  import PaymentServerWeb.Support.AccountsPayments, only: [create_wallet: 1]

  @fetch_wallets """
    query fetchWallets($userId: Integer!) {
      fetchWallets(userId: $userId) {
        amount
      }
    }
  """

  describe "@fetch_wallets" do
    setup [:create_wallet]

    test "returns list of user wallets", %{user: user, wallet: wallet} do
      assert {:ok, %{data: data}} = Absinthe.run(@fetch_wallets, Schema, variables: %{"userId" => user.id})
      assert data["fetchWallets"] |> length === 1
      assert data["fetchWallets"] === [%{"amount" => "#{wallet.amount}"}]
    end
  end

  @fetch_wallet_by_currency  """
    query fetchWalletByCurrency($userId: Integer!, $currencyId: Integer!) {
      fetchWalletByCurrency(userId: $userId, currencyId: $currencyId) {
        amount
      }
    }
  """

  describe "@fetch_wallet_by_currency" do
    setup [:create_wallet]

    test "returns list of user wallets by currency", %{user: user, currency: currency} do
      assert {:ok, %{data: data}} = Absinthe.run(@fetch_wallet_by_currency, Schema, variables: %{"userId" => user.id, "currencyId" => currency.id})
      assert data["fetchWalletByCurrency"]["amount"] === "200.0"
    end
  end

  @fetch_total_worth """
    query fetchTotalWorth($userId: Integer!, $currencyId: Integer!) {
      fetchTotalWorth(userId: $userId, currencyId: $currencyId)
    }
  """

  describe "@fetch_total_worth" do
    setup [:create_wallet]

    test "returns total worth of user", %{user: user, currency: currency} do
      assert {:ok, %{data: data}} = Absinthe.run(@fetch_total_worth, Schema, variables: %{"userId" => user.id, "currencyId" => currency.id})
      assert data["fetchTotalWorth"] === 200.0
    end
  end
end
