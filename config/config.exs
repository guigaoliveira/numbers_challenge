# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :challenge, ChallengeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ChallengeWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Challenge.PubSub,
  live_view: [signing_salt: "OXNtlR/k"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :challenge, Challenge.Scheduler,
  jobs: [
    # At every 30th minute:
    {"*/30 * * * *", {Challenge.Worker, :perform, []}}
  ]

config :challenge, Challenge.Worker,
  default_window: 1..10_000,
  max_retries: 5,
  retry_delay: 100,
  delay_request: 0

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
