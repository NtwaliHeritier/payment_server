defmodule PaymentServer.PaymentComputation.ExchangeMonitorTest do
  use ExUnit.Case, async: true

  alias PaymentServer.PaymentComputation.ExchangeMonitor

  describe "&start_link/1" do
    test "it spawns a process" do
      assert {:ok, pid} = ExchangeMonitor.start_link({"RWF", "EUR"})
      assert Process.whereis(:"RWF/EUR") === pid
      assert ExchangeMonitor.get_exchange_rate(:"RWF/EUR") === "3.1334"
    end
  end
end
