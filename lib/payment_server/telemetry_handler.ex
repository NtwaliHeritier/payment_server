defmodule PaymentServer.TelemetryHandler do
  require Logger

  def attach do
    events = [
      [:payment_server, :exchange_rate, :fetch, :stop],
      [:payment_server, :transfer, :stop],
      [:payment_server, :exchange_monitor, :queue_length]
    ]

    :telemetry.attach_many(
      "payment-server-logger",
      events,
      &__MODULE__.handle_event/4,
      nil
    )
  end

  def handle_event(event, measurements, metadata, _config) do
    Logger.debug(
      "[telemetry] #{inspect(event)} measurements=#{inspect(measurements)} metadata=#{inspect(metadata)}"
    )
  end
end
