defmodule TempSensorUi.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TempSensorUiWeb.Telemetry,
      TempSensorUi.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:temp_sensor_ui, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:temp_sensor_ui, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TempSensorUi.PubSub},

      {Tortoise311.Connection,
       [
         client_id: "phoenix_temp_sensor_ui",
         server: {Tortoise311.Transport.Tcp, host: "45.135.234.114", port: 1883},
         handler: {TempSensorUi.MqttListener, []},
         # Define your topics here. 0 is the QoS level.
         subscriptions: [{"hangar/sensor1", 0}]
       ]},

      # Start a worker by calling: TempSensorUi.Worker.start_link(arg)
      # {TempSensorUi.Worker, arg},
      # Start to serve requests, typically the last entry
      TempSensorUiWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TempSensorUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TempSensorUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end
