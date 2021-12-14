defmodule PaymentServer.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :symbol, :text
    end
  end
end
