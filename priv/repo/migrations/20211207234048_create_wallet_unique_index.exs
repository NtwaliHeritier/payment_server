defmodule PaymentServer.Repo.Migrations.CreateWalletUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:wallets, [:user_id, :currency_id])
  end
end
