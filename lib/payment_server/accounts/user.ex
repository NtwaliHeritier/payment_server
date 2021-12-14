defmodule PaymentServer.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    has_many :wallets, PaymentServer.Payments.Wallet
  end

  @allowed_attributes [:name, :email]

  def changeset(user, attrs) do
    user
    |> cast(attrs, @allowed_attributes)
    |> validate_required(@allowed_attributes)
  end
end
