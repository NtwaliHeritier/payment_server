defmodule PaymentServerWeb.Schema do
  use Absinthe.Schema

  alias PaymentServer.{Repo, Accounts, Payments}

  import_types PaymentServerWeb.Types.{User, Wallet, Currency, Exchange}
  import_types PaymentServerWeb.Schema.Queries.{User, Wallet}
  import_types PaymentServerWeb.Schema.Mutations.{User, Wallet}
  import_types PaymentServerWeb.Schema.Subscriptions.{User, Exchange}

  query do
    import_fields :user_queries
    import_fields :wallet_queries
  end

  mutation do
    import_fields :user_mutations
    import_fields :wallet_mutations
  end

  subscription do
    import_fields :user_subscriptions
    import_fields :exchange_subscriptions
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(Repo)
    loader = Dataloader.new()
              |> Dataloader.add_source(Accounts, source)
              |> Dataloader.add_source(Payments, source)
    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
