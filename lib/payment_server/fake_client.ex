defmodule PaymentServer.FakeClient do
  @behaviour PaymentServer.HTTPClient

  def get(_url) do
    {:error, %{reason: :econnrefused}}
  end
end
