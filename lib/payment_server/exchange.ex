defmodule PaymentServer.Exchange do
  def fetch_exchange_rate(from, to) do
    client = http_client()
    with {:ok, %Req.Response{body: body}} <- client.get("https://api.frankfurter.dev/v1/latest?from=#{from}&to=#{to}") do
        body["rates"][to]
    else
      _ -> :error
    end
  end

  defp http_client do
    Application.get_env(:payment_server, :http_client)
  end
end
