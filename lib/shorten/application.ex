defmodule Shorten.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShortenWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:shorten, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Shorten.PubSub},
      # Start a worker by calling: Shorten.Worker.start_link(arg)
      # {Shorten.Worker, arg},
      # Start to serve requests, typically the last entry
      ShortenWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shorten.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShortenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
