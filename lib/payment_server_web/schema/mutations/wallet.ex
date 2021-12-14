defmodule PaymentServerWeb.Schema.Mutations.Wallet do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers.WalletResolver

  object :wallet_mutations do
    field :create_wallets, :wallet do
      arg :amount, non_null(:float)
      arg :user_id, non_null(:integer)
      arg :currency_id, non_null(:integer)
      resolve &WalletResolver.create_wallet/2
    end

    field :send_money, list_of(:wallet) do
      arg :amount, non_null(:float)
      arg :from, non_null(:integer)
      arg :to, non_null(:integer)
      arg :from_currency_id, non_null(:integer)
      arg :to_currency_id, :integer
      resolve &WalletResolver.send_money/2
    end
  end
end
