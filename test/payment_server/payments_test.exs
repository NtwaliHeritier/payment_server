defmodule PaymentServer.PaymentsTest do
  use PaymentServer.DataCase, async: true
  alias PaymentServer.Payments
  alias PaymentServer.Accounts

  describe "&create_wallet/2" do
    test "creates a new wallet" do
      [user, currency] = create_user_and_currency()
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      assert wallet.amount === 100.0
    end

    test "gives an error tuple when missing a required field" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Payments.create_wallet(%{amount: 100})
    end
  end

  describe "&all_Wallets_by_user_id/1" do
    test "returns list of wallets owned by a specific user" do
      [user, currency] = create_user_and_currency()
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      assert Payments.all_Wallets_by_user_id(user.id) === [wallet]
    end
  end

  describe "&user_wallets_by_currency/2" do
    test "returns user wallets by currency" do
      [user, currency] = create_user_and_currency()
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      assert Payments.user_wallets_by_currency(user.id, currency.id) === wallet
    end
  end

  describe "&total_amount/1" do
    test "returns tuple of currency and amount for each wallet" do
      [user, currency] = create_user_and_currency()
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      assert Payments.total_amount(user.id) === [{currency.symbol, wallet.amount}]
    end
  end

  describe "&update_wallet/2" do
    test "updates a wallet" do
      [user, currency] = create_user_and_currency()
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      attrs = %{amount: 200}
      assert {:ok, wallet} = Payments.update_wallet(wallet, attrs)
      assert wallet.amount === 200.0
    end
  end

  describe "&create_currency/1" do
    test "creates a new currency" do
      assert {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
      assert currency.symbol === "USD"
    end
  end

  describe "&get_currency/1" do
    test "returns currency by id" do
      assert {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
      assert Payments.get_currency(currency.id) === currency
    end
  end

  defp create_user_and_currency do
    {:ok, user} = Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
    {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
    [user, currency]
  end
end
