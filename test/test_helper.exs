ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(PaymentServer.Repo, :manual)

# Mox.defmock(PaymentServer.HTTPClientMock,
#   for: PaymentServer.HTTPClient
# )

# Application.put_env(
#       :payment_server,
#       :http_client,
#       PaymentServer.HTTPClientMock
#     )


# Application.ensure_all_started(:mox)
