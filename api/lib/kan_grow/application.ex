defmodule KanGrow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KanGrowWeb.Telemetry,
      KanGrow.Repo,
      {DNSCluster, query: Application.get_env(:kan_grow, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: KanGrow.PubSub},
      # Start a worker by calling: KanGrow.Worker.start_link(arg)
      # {KanGrow.Worker, arg},
      # Start to serve requests, typically the last entry
      KanGrowWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KanGrow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KanGrowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
