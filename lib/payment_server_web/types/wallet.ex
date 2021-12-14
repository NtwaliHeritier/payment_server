defmodule PaymentServerWeb.Types.Wallet do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  alias PaymentServer.Payments

  object :wallet do
    field :amount, :string
    field :currency, :currency, resolve: dataloader(Payments, :currency)
  end
end
