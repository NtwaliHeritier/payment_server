defmodule PaymentServer.ReqHTTPClient do
  @behaviour PaymentServer.HTTPClient

    @impl true
    def get(url) do
      Req.get(url, receive_timeout: 5_000)
    end
end
