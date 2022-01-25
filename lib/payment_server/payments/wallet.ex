defmodule PaymentServer.Payments.Wallet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "wallets" do
    field :amount, :float
    belongs_to :user, PaymentServer.Accounts.User
    belongs_to :currency, PaymentServer.Payments.Currency
  end

  @allowed_attributes [:amount, :user_id, :currency_id]

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @allowed_attributes)
    |> validate_required(@allowed_attributes)
    |> unique_constraint([:user_id, :currency_id])
  end

  def query_by_user_id(query \\ __MODULE__, user_id) do
    where(query, [w], w.user_id == ^user_id)
  end

  def join_currency(query) do
    join(query, :inner, [w], c in assoc(w, :currency), as: :currency)
  end

  def get_wallets_by_currency(query, currency_id) do
    where(query, [currency: c], c.id == ^currency_id)
  end

  def select_amount_currency(query) do
    select(query, [w, c], {c.symbol, w.amount})
  end
end
