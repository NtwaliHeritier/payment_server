defmodule PaymentServer.Exchange.PaymentSource do
  @callback fetch(from :: String.t(), to :: String.t()) :: {:ok, term()} | {:error, term()}

  def fetch_exchange_rate(from, to) do
    with {:ok, %{body: body}} <- fetch_api(source(), from, to),
    {:ok, currency_exchange_rate} <- decode_json(body) do
      currency_exchange_rate["Realtime Currency Exchange Rate"]["5. Exchange Rate"]
    else
      _ -> :error
    end
  end

  defp fetch_api(source, from, to) do
    case source.fetch(from, to) do
      {:ok, data} -> {:ok, data}
      _ -> nil
    end
  end

  defp decode_json(body) do
    Jason.decode(body)
  end

  defp source do
    Application.get_env(:payment_server, :source)
  end
end
