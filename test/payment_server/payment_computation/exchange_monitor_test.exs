defmodule PaymentServer.PaymentComputation.ExchangeMonitorTest do
  use ExUnit.Case

  import Mox

  setup :set_mox_global
  setup :verify_on_exit!

  alias PaymentServer.PaymentComputation.ExchangeMonitor

  setup do
    expect(PaymentServer.HTTPClientMock, :get, fn url ->
      assert url =~ "from=CAD"

      {:ok,
       %Req.Response{
         status: 200,
         body: %{"rates" => %{"EUR" => 0.860981}}
       }}
    end)

    start_supervised!({PaymentServer.PaymentComputation.ExchangeMonitor, {"CAD", "EUR"}})
    :ok
  end

  describe "&start_link/1" do
    test "it spawns a process" do
      assert ExchangeMonitor.get_exchange_rate("CAD", "EUR") === {:ok, 0.860981}
    end
  end
end
