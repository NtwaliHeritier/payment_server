defmodule PaymentServerWeb.Types.Currency do
  use Absinthe.Schema.Notation

  object :currency do
    field :symbol, :string
  end
end
