defmodule PaymentServerWeb.Schema.Mutations.User do
  use Absinthe.Schema.Notation
  alias PaymentServerWeb.Resolvers.UserResolver

  object :user_mutations do
    field :create_users, :user do
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      resolve &UserResolver.create_user/2
    end
  end
end
