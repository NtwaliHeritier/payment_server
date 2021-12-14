defmodule PaymentServer.Exchange.PaymentHttp do
  @behaviour PaymentServer.Exchange.PaymentSource

  @impl PaymentServer.Exchange.PaymentSource
  def fetch(from, to) do
    HTTPoison.get("http://localhost:4001/query?function=CURRENCY_EXCHANGE_RATE&from_currency=#{from}&to_currency=#{to}&apikey=demo")
  end
end
