defmodule PaymentServerWeb.Schema.Queries.UserTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.Accounts
  alias PaymentServerWeb.Schema

  @users_query """
    query fetchUsers {
      fetchUsers {
        email
        name
      }
    }
  """

  describe "@fetch_users" do
    test "returns list of users" do
      Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
      assert {:ok, %{data: data}} = Absinthe.run(@users_query, Schema)
      assert data["fetchUsers"] |> length() === 1
    end
  end
end
