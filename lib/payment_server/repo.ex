defmodule PaymentServer.Repo do
  use Ecto.Repo,
    otp_app: :payment_server,
    adapter: Ecto.Adapters.Postgres
end
