defmodule PaymentServerWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
      {TelemetryMetricsPrometheus,
       metrics: metrics(), port: 9568, plug_cowboy_opts: [ip: {0, 0, 0, 0}]}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      summary("payment_server.repo.query.total_time", unit: {:native, :millisecond}),
      summary("payment_server.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("payment_server.repo.query.query_time", unit: {:native, :millisecond}),
      summary("payment_server.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("payment_server.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),

      # Custom metrics
      distribution(
        "payment_server.exchange_rate.fetch.stop.duration",
        event_name: [:payment_server, :exchange_rate, :fetch, :stop],
        measurement: :duration,
        unit: {:native, :millisecond},
        tags: [:currency_pair, :result],
        reporter_options: [
          buckets: [10, 25, 50, 100, 250, 500, 1000, 2500, 5000]
        ]
      ),
      distribution(
        "payment_server.transfer.stop.duration",
        event_name: [:payment_server, :transfer, :stop],
        measurement: :duration,
        unit: {:native, :millisecond},
        tags: [:currency_pair, :result],
        reporter_options: [
          buckets: [10, 25, 50, 100, 250, 500, 1000, 2500]
        ]
      ),
      counter(
        "payment_server.exchange_rate.fetch.stop.count",
        event_name: [:payment_server, :exchange_rate, :fetch, :stop],
        tags: [:currency_pair, :result]
      ),
      counter(
        "payment_server.transfer.stop.count",
        event_name: [:payment_server, :transfer, :stop],
        tags: [:currency_pair, :result]
      ),
      last_value(
        "payment_server.exchange_monitor.queue_length.size",
        event_name: [:payment_server, :exchange_monitor, :queue_length],
        measurement: :size
      ),
      last_value("vm.system_counts.process_count")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {PaymentServerWeb, :count_users, []}
    ]
  end
end
