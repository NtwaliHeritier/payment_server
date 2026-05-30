defmodule PaymentServer.HTTPClient do
  @callback get(String.t()) ::
              {:ok, Req.Response.t()} | {:error, term()}
end
