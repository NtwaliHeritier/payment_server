defmodule PaymentServerWeb.Schema.Queries.User do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers.UserResolver

  object :user_queries do
    field :fetch_users, list_of(:user) do
      resolve &UserResolver.all_users/2
    end
  end
end
