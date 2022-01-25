defmodule PaymentServerWeb.Resolvers.UserResolver do
  alias PaymentServer.Accounts

  def all_users(_, _) do
    {:ok, Accounts.all_users}
  end

  def get_user(%{user_id: user_id}, _) do
    {:ok, Accounts.get_user(user_id)}
  end

  def create_user(params, _) do
    with {:ok, user} <- Accounts.create_user(params) do
        {:ok, user}
    else
      _ ->
        {:error, message: "Could not create user", details: "New user could not be created"}
    end
  end
end
