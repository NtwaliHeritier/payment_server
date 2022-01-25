defmodule PaymentServerWeb.Schema.Queries.User do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers.UserResolver

  object :user_queries do
    field :fetch_users, list_of(:user) do
      resolve &UserResolver.all_users/2
    end

    field :fetch_user, :user do
      arg :user_id, non_null(:integer)
      resolve &UserResolver.get_user/2
    end
  end
end
