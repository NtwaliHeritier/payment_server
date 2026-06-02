defmodule PaymentServer.Exchange do
  def fetch_exchange_rate(from, to) do
    client = http_client()

    case client.get("https://api.frankfurter.dev/v1/latest?from=#{from}&to=#{to}") do
      {:ok, %Req.Response{body: body}} ->
        exchange_rate = body["rates"][to]

        if is_number(exchange_rate) and exchange_rate > 0.0 do
          {:ok, exchange_rate}
        else
          {:error, :invalid_exchange_rate}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp http_client do
    Application.get_env(:payment_server, :http_client)
  end
end
