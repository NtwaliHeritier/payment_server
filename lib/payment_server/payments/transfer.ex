defmodule PaymentServer.Payments.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transfers" do
    field :idempotency_key, :string
    field :amount_sent, :decimal
    field :amount_received, :decimal
    field :exchange_rate, :float

    belongs_to :from_wallet, PaymentServer.Payments.Wallet
    belongs_to :to_wallet, PaymentServer.Payments.Wallet

    timestamps()
  end

  def changeset(transfer, attrs) do
    transfer
    |> cast(attrs, [
      :idempotency_key,
      :amount_sent,
      :amount_received,
      :exchange_rate,
      :from_wallet_id,
      :to_wallet_id
    ])
    |> validate_required([
      :idempotency_key,
      :amount_sent,
      :amount_received,
      :exchange_rate,
      :from_wallet_id,
      :to_wallet_id
    ])
    |> validate_number(:amount_sent, greater_than: 0)
    |> validate_number(:amount_received, greater_than: 0)
    |> validate_number(:exchange_rate, greater_than: 0)
    |> unique_constraint(:idempotency_key, name: :transfers_from_wallet_id_idempotency_key_index)
  end
end
