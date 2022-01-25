defmodule PaymentServer.Accounts do
  alias PaymentServer.Accounts.User
  alias EctoShorts.Actions

  def create_user(params) do
    Actions.create(User, params)
  end

  def all_users, do: Actions.all(User)

  def get_user(user_id), do: Actions.get(User, user_id)
end
