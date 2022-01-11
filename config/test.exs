import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :challenge, ChallengeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "qSGVwzDppi7H37eJAmo4CDq0iyNsF6HJZAGz6N+SzRajAY2a1D3FyQMyBbFyAGpK",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
