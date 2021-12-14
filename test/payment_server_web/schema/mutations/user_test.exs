defmodule PaymentServerWeb.Schema.Mutations.UserTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServerWeb.Schema

  @create_users """
    mutation createUsers($name: String!, $email: String!) {
      createUsers(name: $name, email: $email) {
        name
        email
      }
    }
  """

  describe "@create_users" do
    test "creates a new user" do
      assert {:ok, %{data: data}} = Absinthe.run(@create_users, Schema, variables: %{"name" => "Heritier", "email" => "heritier@gmail.com"})
      assert data["createUsers"]["email"] === "heritier@gmail.com"
      assert data["createUsers"]["name"] === "Heritier"
    end
  end
end
