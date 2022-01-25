defmodule PaymentServer.Payments.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :symbol, :string
  end

  @allowed_attributes [:symbol]

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(currency, attrs) do
    currency
    |> cast(attrs, @allowed_attributes)
    |> unique_constraint(:symbol)
  end
end
