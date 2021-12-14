defmodule PaymentServer.Repo.Migrations.AlterCurrencySymbol do
  use Ecto.Migration

  def change do
    alter table(:currencies) do
      remove :symbol
      add :symbol, :text, unique: true
    end
  end
end
