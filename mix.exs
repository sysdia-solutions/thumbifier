defmodule Thumbifier.Mixfile do
  use Mix.Project

  def project do
    [app: :thumbifier,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Thumbifier, []},
     applications: [:phoenix, :cowboy, :logger, :postgrex,
                    :poolboy, :httpoison, :mailman, :phoenix_html,
                    :phoenix_ecto, :timex, :sh, :corsica,
                    :logger_logentries_backend]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.0.4"},
     {:phoenix_ecto, "~> 1.1"},
     {:phoenix_html, "~> 2.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:exrm, "~> 1.0.0-rc7"},
     {:cowboy, "~> 1.0"},
     {:timex, "~> 1.0.0-rc3"},
     {:poolboy, "~> 1.5.1"},
     {:mock, "~> 0.1.1", only: :test},
     {:sh, "~> 1.1"},
     {:httpoison, "~> 0.8"},
     {:mailman, "~> 0.2"},
     {:eiconv, github: "zotonic/eiconv"},
     {:corsica, "~> 0.4.0"},
     {:logger_logentries_backend, "~> 0.0.1", only: :prod}
     ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
    "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
