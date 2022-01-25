defmodule PaymentServerWeb.Subscriptions.ExchangeTest do
  use PaymentServerWeb.SubscriptionCase, async: true
  alias PaymentServer.Payments

  @subcribe_all_exchange_rate_change """
    subscription subscribeAllExchangeRateChange {
      subscribeAllExchangeRateChange {
        from
        to
        exchangeRate
      }
    }
  """

  describe "@subscribe_all_exchange_rate_change" do
    test "shows realtime exchange rate for all currencies", %{socket: socket} do
      ref = push_doc socket, @subcribe_all_exchange_rate_change
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      assert_push "subscription:data", data, 1000
      assert %{
        subscriptionId: ^subscription_id
      } = data
    end
  end

  @subscribe_exchange_rate_change """
    subscription subscribeExchangeRateChange($from: Integer!, $to: Integer!) {
      subscribeExchangeRateChange(from: $from, to: $to) {
        from
        to
        exchangeRate
      }
    }
  """

  describe "@subscribe_exchange_rate_change" do
    test "shows realtime exchange rate for specific currencies", %{socket: socket} do
      assert {:ok, from_currency} = Payments.create_currency(%{symbol: "USD"})
      assert {:ok, to_currency} = Payments.create_currency(%{symbol: "EUR"})
      ref = push_doc socket, @subscribe_exchange_rate_change, variables: %{"from" => from_currency.id, "to" => to_currency.id}
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      assert_push "subscription:data", data, 1000
      assert %{
        subscriptionId: ^subscription_id
      } = data
    end
  end
end
