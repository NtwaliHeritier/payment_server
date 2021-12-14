defmodule PaymentServer.Exchange.PaymentSourceTest do
  use ExUnit.Case, async: true

  alias PaymentServer.Exchange.PaymentSource

  describe "&fetch_exchange_rate/2" do
    test "returns exchange rate" do
      assert PaymentSource.fetch_exchange_rate("USD", "CAD") === "3.1334"
    end
  end
end
