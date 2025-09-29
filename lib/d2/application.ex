defmodule D2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      D2Web.Telemetry,
      {DNSCluster, query: Application.get_env(:d2, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: D2.PubSub},
      # Start a worker by calling: D2.Worker.start_link(arg)
      # {D2.Worker, arg},
      # Start to serve requests, typically the last entry
      D2Web.Endpoint,
      # My own stuff
      {DynamicSupervisor, strategy: :one_for_one, name: D2.DynamicSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: D2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    D2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
