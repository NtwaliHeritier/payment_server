defmodule PaymentServer.Accounts do
  alias PaymentServer.Accounts.User
  alias PaymentServer.Repo

  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def all_users, do: Repo.all(User)
end
