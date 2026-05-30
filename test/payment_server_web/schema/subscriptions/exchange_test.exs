defmodule PaymentServerWeb.Subscriptions.ExchangeTest do
  use PaymentServerWeb.SubscriptionCase
  alias PaymentServer.Payments

  import Mox

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
      expect(PaymentServer.HTTPClientMock, :get, fn url ->
        assert url =~ "from=USD"
        {:ok,
        %Req.Response{
          status: 200,
          body: %{"rates" => %{"EUR" => 0.860}}
        }}
      end)
    start_supervised!({PaymentServer.PaymentComputation.ExchangeMonitor, {"USD", "EUR"}})
    :ok
  end

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
      expect(PaymentServer.HTTPClientMock, :get, fn url ->
        assert url =~ "from=USD"
        {:ok,
        %Req.Response{
          status: 200,
          body: %{"rates" => %{"EUR" => 0.860}}
        }}
      end)

      ref = push_doc socket, @subcribe_all_exchange_rate_change
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      assert_push "subscription:data", data, 2000
      assert %{
        subscriptionId: ^subscription_id
      } = data
    end
  end

  @subscribe_exchange_rate_change """
    subscription subscribeExchangeRateChange($from: Int!, $to: Int!) {
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

      expect(PaymentServer.HTTPClientMock, :get, fn url ->
        assert url =~ "from=USD"
        {:ok,
        %Req.Response{
          status: 200,
          body: %{"rates" => %{"EUR" => 0.860}}
        }}
      end)

      ref = push_doc socket, @subscribe_exchange_rate_change, variables: %{"from" => from_currency.id, "to" => to_currency.id}
      assert_reply ref, :ok, %{subscriptionId: subscription_id}
      assert_push "subscription:data", data, 2000
      assert %{
        subscriptionId: ^subscription_id
      } = data
    end
  end
end
