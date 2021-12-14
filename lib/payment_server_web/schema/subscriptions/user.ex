defmodule PaymentServerWeb.Schema.Subscriptions.User do
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    field :total_worth_change_by_user, list_of(:wallet) do
      arg :user_id, non_null(:integer)

      trigger :create_wallets, topic: fn
        %{user_id: user_id} ->
          "updated_worth_of#{user_id}"
        end

      trigger :send_money, topic: fn wallets ->
        Enum.map(wallets, fn wallet ->
          "updated_worth_of#{wallet.user_id}"
        end)
      end

      config fn
        %{user_id: user_id}, _ ->
          {:ok, topic: "updated_worth_of#{user_id}"}
      end
    end
  end
end
