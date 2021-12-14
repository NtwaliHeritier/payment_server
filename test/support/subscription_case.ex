defmodule PaymentServerWeb.SubscriptionCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use PaymentServerWeb.ChannelCase
      use Absinthe.Phoenix.SubscriptionTest, schema: PaymentServerWeb.Schema

      setup do
        {:ok, socket} = Phoenix.ChannelTest.connect(PaymentServerWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)
        {:ok, %{socket: socket}}
      end
    end
  end
end
