defmodule PaymentServerWeb.Schema.Subscriptions.UserTest do
  use PaymentServerWeb.SubscriptionCase, async: true
  alias PaymentServer.{Accounts, Payments}

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
    test "shows real time data whenever user creates a new wallet", %{socket: socket} do
      [user, currency] = create_wallet()
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

    test "shows real time data when transfering money", %{socket: socket} do
      [user1, user2, currency] = create_wallets()
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
