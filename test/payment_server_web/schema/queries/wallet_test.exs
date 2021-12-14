defmodule PaymentServerWeb.Schema.Queries.WalletTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.{Accounts, Payments}
  alias PaymentServerWeb.Schema

  @fetch_wallets """
    query fetchWallets($userId: Integer!) {
      fetchWallets(userId: $userId) {
        amount
      }
    }
  """

  describe "@fetch_wallets" do
    test "returns list of user wallets" do
      [wallet, user, _] = create_wallet()
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
    test "returns list of user wallets by currency" do
      [_, user, currency] = create_wallet()
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
    test "returns total worth of user" do
      [_, user, currency] = create_wallet()
      assert {:ok, %{data: data}} = Absinthe.run(@fetch_total_worth, Schema, variables: %{"userId" => user.id, "currencyId" => currency.id})
      assert data["fetchTotalWorth"] === 200.0
    end
  end

  defp create_wallet do
    {:ok, user} = Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
    {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
    {:ok, wallet} = Payments.create_wallet(%{amount: 200, user_id: user.id, currency_id: currency.id})
    [wallet, user, currency]
  end
end
