defmodule PaymentServer.AccountsTest do
  use PaymentServer.DataCase, async: true
  alias PaymentServer.Accounts

  setup do
    params = %{email: "heritier@gmail.com", name: "NTWALI Heritier"}
    {:ok, params: params}
  end

  describe "&create_user/2" do
    test "creates a new user", %{params: params} do
      assert {:ok, user} = Accounts.create_user(params)
      assert user.email === "heritier@gmail.com"
    end

    test "gives an error tuple when missing a required field" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Accounts.create_user(%{email: "heritier@gmail.com"})
    end
  end

  describe "&all_users/0" do
    test "returns list of users", %{params: params} do
      Accounts.create_user(params)
      users = Accounts.all_users()
      assert length(users) === 1
    end
  end
end
