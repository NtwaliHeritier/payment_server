defmodule PaymentServer.ExchangeTest do
  use ExUnit.Case, async: true

  alias PaymentServer.Exchange

  describe "&fetch_exchange_rate/2" do
    test "returns exchange rate" do
      assert Exchange.fetch_exchange_rate("USD", "CAD") === "3.1334"
    end
  end
end
