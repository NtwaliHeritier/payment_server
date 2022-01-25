defmodule PaymentServerWeb.Support.AccountsPayments do
  alias PaymentServer.{Accounts, Payments}

  def create_user(_opts \\ []) do
    {:ok, user} = Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
    %{user: user}
  end

  def create_currency(_opts \\ []) do
    {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
    %{currency: currency}
  end

  def create_wallets(_opts \\ []) do
    {:ok, user1} = Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
    {:ok, user2} = Accounts.create_user(%{email: "ishkev@gmail.com", name: "ISHIMWE Kevin"})
    {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
    {:ok, _} = Payments.create_wallet(%{amount: 200, user_id: user1.id, currency_id: currency.id})
    {:ok, _} = Payments.create_wallet(%{amount: 100, user_id: user2.id, currency_id: currency.id})
    %{user1: user1, user2: user2, currency: currency}
  end

  def create_wallet(_opts \\ []) do
    {:ok, user} = Accounts.create_user(%{email: "heritier@gmail.com", name: "NTWALI Heritier"})
    {:ok, currency} = Payments.create_currency(%{symbol: "USD"})
    {:ok, wallet} = Payments.create_wallet(%{amount: 200, user_id: user.id, currency_id: currency.id})
    %{wallet: wallet, user: user, currency: currency}
  end
end
