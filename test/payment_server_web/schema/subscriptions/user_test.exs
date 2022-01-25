defmodule PaymentServerWeb.Schema.Subscriptions.UserTest do
  use PaymentServerWeb.SubscriptionCase, async: true

  import PaymentServerWeb.Support.AccountsPayments, only: [create_wallets: 1, create_user: 1, create_currency: 1]

  @create_wallets """
    mutation createWallets($amount: Integer!, $userId: Integer!, $currencyId: Integer!) {
      createWallets(amount: $amount, userId: $userId, currencyId: $currencyId) {
        amount
      }
    }
  """

  @send_money """
    mutation sendMoney($amount: Float!, $from: Integer!, $to: Integer!, $fromCurrencyId: Integer!, $toCurrencyId: Int) {
      sendMoney(amount: $amount, from: $from, to: $to, fromCurrencyId: $fromCurrencyId, toCurrencyId: $toCurrencyId) {
        amount
      }
    }
  """

  @total_worth_change_by_user """
    subscription totalWorthChangeByUser($userId: Integer!) {
      totalWorthChangeByUser(userId: $userId) {
        amount
      }
    }
  """

  describe "@total_worth_change_by_user" do
    setup [:create_currency, :create_user]

    test "shows real time data whenever user creates a new wallet", %{socket: socket, user: user, currency: currency} do
      ref = push_doc socket, @total_worth_change_by_user, variables: %{"userId" => user.id}
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      ref = push_doc socket, @create_wallets, variables: %{"userId" => user.id, "amount" => 100, "currencyId" => currency.id}
      assert_reply ref, :ok, %{data: data}
      assert %{
        "createWallets" => %{
          "amount" => "100.0"
        }
      } = data
      assert_push "subscription:data", data
      assert %{
                subscriptionId: ^subscription_id,
                result: %{data: %{"totalWorthChangeByUser" => [%{"amount" => "100.0"}]}}
              } = data
    end
  end

  describe "@total_worth_change_by_user1" do
    setup [:create_wallets]

    test "shows real time data when transfering money", %{socket: socket, user1: user1, user2: user2, currency: currency} do
      ref = push_doc(socket, @total_worth_change_by_user, variables: %{"userId" => user1.id})
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      ref = push_doc(socket, @send_money, variables: %{"amount" => 20, "from" => user1.id, "to" => user2.id, "fromCurrencyId" => currency.id})
      assert_reply ref, :ok, %{data: data}
      assert %{"sendMoney" => [%{"amount" => "180.0"}, %{"amount" => "120.0"}]} = data
      assert_push "subscription:data", data
      assert %{
        subscriptionId: ^subscription_id
      } = data
    end
  end
end
