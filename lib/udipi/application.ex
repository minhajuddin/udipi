defmodule Udipi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Udipi.Repo,
      # Start the Telemetry supervisor
      UdipiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Udipi.PubSub},
      # Start the Endpoint (http/https)
      UdipiWeb.Endpoint
      # Start a worker by calling: Udipi.Worker.start_link(arg)
      # {Udipi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Udipi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UdipiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
