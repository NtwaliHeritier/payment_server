defmodule PaymentServer.Repo.Migrations.AddCurrencyUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:currencies, [:symbol])
  end
end
