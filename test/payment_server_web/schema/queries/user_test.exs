defmodule PaymentServerWeb.Schema.Queries.UserTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema

  import PaymentServerWeb.Support.AccountsPayments, only: [create_user: 1]

  @users_query """
    query fetchUsers {
      fetchUsers {
        email
        name
      }
    }
  """

  describe "@fetch_users" do
    setup [:create_user]
    test "returns list of users" do
      assert {:ok, %{data: data}} = Absinthe.run(@users_query, Schema)
      assert length(data["fetchUsers"]) === 1
    end
  end

  @user_query """
    query fetchUser($userId: Integer!) {
      fetchUser(userId: $userId) {
        name
        email
      }
    }
  """

  describe "@fetch_user" do
    setup [:create_user]
    test "returns the user", %{user: user} do
      assert {:ok, %{data: data}} = Absinthe.run(@user_query, Schema, variables: %{"userId" => user.id})
      assert data["fetchUser"]["email"] == "heritier@gmail.com"
    end
  end
end
