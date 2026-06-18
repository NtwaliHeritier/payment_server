defmodule PaymentServer.Repo.Migrations.AddTableTransfers do
  use Ecto.Migration

  def change do
    create table(:transfers) do
      add :idempotency_key, :string, null: false
      add :from_wallet_id, references(:wallets, on_delete: :nothing), null: false
      add :to_wallet_id, references(:wallets, on_delete: :nothing), null: false
      add :amount_sent, :decimal, null: false
      add :amount_received, :decimal, null: false
      add :exchange_rate, :float, null: false
      timestamps()
    end

    create unique_index(:transfers, [:from_wallet_id, :idempotency_key])
    create index(:transfers, [:from_wallet_id])
    create index(:transfers, [:to_wallet_id])
  end
end
