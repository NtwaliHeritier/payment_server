defmodule PaymentServer.PaymentComputation.PaymentCalculationTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.PaymentComputation.PaymentCalculation
  alias PaymentServer.{Payments, Accounts}

  describe "&get_total_amount/2" do
    test "returns sum of amount in wallets" do
      assert PaymentCalculation.get_total_amount([{"USD", 200}, {"EUR", 300}], "USD") === 1140.02
    end
  end

  describe "&check_if_sufficient_money/2" do
    test "returns if balance is sufficient to send money" do
      assert PaymentCalculation.check_if_sufficient_money(100, 200) === false
      assert PaymentCalculation.check_if_sufficient_money(200, 100) === true
    end
  end

  describe "&transfer_money/5" do
    test "transfers money from one wallet to another" do
      [sender_wallet, receiver_wallet] = create_wallets()
      [sender_wallet, receiver_wallet] = PaymentCalculation.transfer_money(sender_wallet, receiver_wallet, 20, "USD", "USD")
      assert sender_wallet.amount === 180.0
      assert receiver_wallet.amount === 120.0
    end
  end

  defp create_wallets do
    {:ok, user1} = Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
    {:ok, user2} = Accounts.create_user(%{email: "ishkev@gmail.com", name: "ISHIMWE Kevin"})
    {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
    {:ok, wallet1} = Payments.create_wallet(%{amount: 200, user_id: user1.id, currency_id: currency.id})
    {:ok, wallet2} = Payments.create_wallet(%{amount: 100, user_id: user2.id, currency_id: currency.id})
    [wallet1, wallet2]
  end
end
