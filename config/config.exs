# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General config
config :thumbifier,
  poolboy_size: System.get_env("ENV_THUMBIFIER_POOLBOY_SIZE") || "2" |> String.to_integer,
  poolboy_max_overflow: System.get_env("ENV_THUMBIFIER_POOLBOY_MAX_OVERFLOW") || "1" |> String.to_integer

# Configures the endpoint
config :thumbifier, Thumbifier.Endpoint,
  url: [host: "localhost"],
  root: Path.expand("..", __DIR__),
  secret_key_base: System.get_env("ENV_THUMBIFIER_SECRET_KEY_BASE") || "iZqydsfgSlkqOK8KQN2KYtNLYRHVFgbeBUja/ktWJffOHyRfy5k94PPGS0L4+1ON",
  debug_errors: false,
  pubsub: [name: Thumbifier.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :phoenix, filter_parameters: ["api_token", "api_grant"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure your database
config :thumbifier, Thumbifier.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("ENV_THUMBIFIER_DB_HOSTNAME"),
  port: System.get_env("ENV_THUMBIFIER_DB_PORT") || "5432"  |> String.to_integer,
  username: System.get_env("ENV_THUMBIFIER_DB_USERNAME") || "postgres",
  password: System.get_env("ENV_THUMBIFIER_DB_PASSWORD") || "postgres",
  database: System.get_env("ENV_THUMBIFIER_DB_DATABASE") || "thumbifier_db"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

if File.exists? "config/#{Mix.env}.secret.exs" do
  import_config "#{Mix.env}.secret.exs"
end
