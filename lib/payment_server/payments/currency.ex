defmodule PaymentServer.Payments.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :symbol, :string
  end

  @allowed_attributes [:symbol]

  def changeset(currency, attrs) do
    currency
    |> cast(attrs, @allowed_attributes)
    |> unique_constraint(:symbol)
  end
end
