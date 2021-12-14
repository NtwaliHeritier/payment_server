defmodule PaymentServer.Exchange.PaymentFake do
  @behaviour PaymentServer.Exchange.PaymentSource
  def fetch(_from, _to) do
    {:ok,
      %HTTPoison.Response{
        body:
        "{\"Realtime Currency Exchange Rate\":{\"5. Exchange Rate\":\"3.1334\"}}"
        }
      }
  end
end
