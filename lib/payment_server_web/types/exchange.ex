defmodule PaymentServerWeb.Types.Exchange do
  use Absinthe.Schema.Notation

  object :currency_exchange do
    field :from, :string
    field :to, :string
    field :exchange_rate, :string
  end
end
