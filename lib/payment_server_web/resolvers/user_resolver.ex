defmodule PaymentServerWeb.Resolvers.UserResolver do
  alias PaymentServer.Accounts

  def all_users(_, _) do
    {:ok, Accounts.all_users}
  end

  def create_user(params, _) do
    case Accounts.create_user(params) do
      {:ok, user} ->
        {:ok, user}
      {:error, _} ->
        {:error, message: "Could not create user", details: "New user could not be created"}
    end
  end
end
