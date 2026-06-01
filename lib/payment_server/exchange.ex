defmodule PaymentServer.Exchange do
  def fetch_exchange_rate(from, to) do
    client = http_client()
    case client.get("https://api.frankfurter.dev/v1/latest?from=#{from}&to=#{to}") do
      {:ok, %Req.Response{body: body}} ->
        {:ok, body["rates"][to]}
      {:error, reason} ->
        {:error, {:http_error, reason}}
    end
  end

  defp http_client do
    Application.get_env(:payment_server, :http_client)
  end
end
