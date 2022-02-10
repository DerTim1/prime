defmodule Prim.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      Application.get_env(:prim, Prim.Application, :main)
      |> children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Prim.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children(:worker) do
    [
      {Cluster.Supervisor,
       [Application.get_env(:libcluster, :topologies, []), [name: MyApp.ClusterSupervisor]]}
    ]
  end

  defp children(_) do
    [
      # Start the Telemetry supervisor
      PrimWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Prim.PubSub},
      # Start the Endpoint (http/https)
      PrimWeb.Endpoint,
      # Start a worker by calling: Prim.Worker.start_link(arg)
      # {Prim.Worker, arg},
      {Prim.Primes, 11},
      {Cluster.Supervisor,
       [Application.get_env(:libcluster, :topologies, []), [name: MyApp.ClusterSupervisor]]}
    ]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PrimWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
