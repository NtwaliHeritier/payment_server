defmodule PaymentServer.PaymentsTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.Payments

  import PaymentServerWeb.Support.AccountsPayments, only: [create_currency: 1, create_user: 1]

  describe "&create_wallet/2" do
    setup [:create_user, :create_currency]

    test "creates a new wallet", %{user: user, currency: currency} do
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      assert wallet.amount === 100.0
    end

    test "gives an error tuple when missing a required field" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Payments.create_wallet(%{amount: 100})
    end
  end

  describe "&all_Wallets_by_user_id/1" do
    setup [:create_user, :create_currency]

    test "returns list of wallets owned by a specific user", %{user: user, currency: currency} do
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      assert Payments.all_Wallets_by_user_id(%{user_id: user.id}) === [wallet]
    end
  end

  describe "&user_wallets_by_currency/2" do
    setup [:create_user, :create_currency]

    test "returns user wallets by currency", %{user: user, currency: currency} do
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      assert Payments.user_wallets_by_currency(user.id, currency.id) === wallet
    end
  end

  describe "&total_amount/1" do
    setup [:create_user, :create_currency]

    test "returns tuple of currency and amount for each wallet", %{user: user, currency: currency} do
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      assert Payments.total_amount(user.id) === [{currency.symbol, wallet.amount}]
    end
  end

  describe "&update_wallet/2" do
    setup [:create_user, :create_currency]

    test "updates a wallet", %{user: user, currency: currency} do
      assert {:ok, wallet} = Payments.create_wallet(%{amount: 100, user_id: user.id, currency_id: currency.id})
      attrs = %{amount: 200}
      assert {:ok, %{amount: amount}} = Payments.update_wallet(wallet, attrs)
      assert amount === 200.0
    end
  end

  describe "&create_currency/1" do
    setup [:create_currency]

    test "creates a new currency", %{currency: currency} do
      assert currency.symbol === "USD"
    end
  end

  describe "&get_currency/1" do
    setup [:create_currency]

    test "returns currency by id", %{currency: currency} do
      assert Payments.get_currency(currency.id) === currency
    end
  end
end
