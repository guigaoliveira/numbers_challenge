defmodule Challenge.Application do
  @moduledoc """
  Challenge Application
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChallengeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Challenge.PubSub},
      # Start the Endpoint (http/https)
      ChallengeWeb.Endpoint,
      # Start Finch HTTP Client
      {Finch, name: Finch},
      # Start Cache
      Challenge.Cache,
      # Start Quantum Scheduler
      Challenge.Scheduler,
      # Start Task Supervisor
      {Task.Supervisor, name: Challenge.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Challenge.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChallengeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
