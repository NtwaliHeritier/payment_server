# PaymentServer

This is a graphql api used to handle transactions. It fetches exchange rates of different currencies from an external api(they change every second), and uses OTP genservers to update the exchange each second.

Built using:
- Elixir
- Phoenix
- Absinthe/Graphql

To run it locally:
- clone this repo: `git clone https://github.com/NtwaliHeritier/payment_server`
- Update your database credentials in config/dev.exs
- Run `mix ecto.setup` to create and migrate your database
- Run `mix phx.server` to start your server
- Now you can visit [`localhost:4000`](http://localhost:4000) from your browser and use the graphql playground
