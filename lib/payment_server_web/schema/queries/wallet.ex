defmodule PaymentServerWeb.Schema.Queries.Wallet do
  use Absinthe.Schema.Notation

  alias PaymentServerWeb.Resolvers.WalletResolver

  object :wallet_queries do
    field :fetch_wallets, list_of(:wallet) do
      arg :user_id, non_null(:integer)
      resolve &WalletResolver.all_wallets_by_user_id/2
    end

    field :fetch_wallet_by_currency, :wallet do
      arg :user_id, non_null(:integer)
      arg :currency_id, non_null(:integer)
      resolve &WalletResolver.user_wallets_by_currency/2
    end

    field :fetch_total_worth, :float do
      arg :user_id, non_null(:integer)
      arg :currency_id, non_null(:integer)
      resolve &WalletResolver.user_total_worth/2
    end
  end
end
