defmodule PaymentServer.ExchangeTest do
  use ExUnit.Case

  import Mox

  setup :verify_on_exit!

  alias PaymentServer.Exchange

  describe "&fetch_exchange_rate/2" do
    test "returns exchange rate" do
      expect(PaymentServer.HTTPClientMock, :get, fn url ->
        assert url =~ "from=USD"

        {:ok,
        %Req.Response{
          status: 200,
          body: %{"rates" => %{"CAD" => 0.81, "EUR" => 0.23}}
        }}
      end)
      assert {:ok, exchange_rate} = Exchange.fetch_exchange_rate("USD", "EUR")
      assert exchange_rate === 0.23
    end
  end
end
