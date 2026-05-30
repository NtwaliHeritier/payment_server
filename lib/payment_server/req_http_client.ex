defmodule PaymentServer.ReqHTTPClient do
  @behaviour PaymentServer.HTTPClient

    @impl true
  def get(url) do
    Req.get(url)
  end
end
