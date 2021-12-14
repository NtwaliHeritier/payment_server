defmodule PaymentServerWeb.Schema.Subscriptions.Exchange do
  use Absinthe.Schema.Notation
  alias PaymentServer.Payments

  object :exchange_subscriptions do
    field :subscribe_exchange_rate_change, :currency_exchange do
      arg :from, non_null(:integer)
      arg :to, non_null(:integer)
      config fn %{from: from, to: to}, _ ->
        from_currency = Payments.get_currency(from)
        to_currency = Payments.get_currency(to)
        {:ok, topic: "rate_update#{from_currency.symbol}/#{to_currency.symbol}"}
      end
    end

    field :subscribe_all_exchange_rate_change, :currency_exchange do
      config fn _, _ ->
        {:ok, topic: "exchange_rate_update"}
      end
    end
  end
end
