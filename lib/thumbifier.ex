defmodule Thumbifier do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    poolboy_config = [
      {:name, {:local, :thumbifier}},
      {:worker_module, Thumbifier.Convert.Worker},
      {:size, Application.get_env(:thumbifier, :poolboy_size)},
      {:max_overflow, Application.get_env(:thumbifier, :poolboy_max_overflow)}
    ]

    children = [
      # Start the endpoint when the application starts
      supervisor(Thumbifier.Endpoint, []),
      # Start the Ecto repository
      worker(Thumbifier.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(Thumbifier.Worker, [arg1, arg2, arg3]),
      :poolboy.child_spec(:thumbifier, poolboy_config, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Thumbifier.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Thumbifier.Endpoint.config_change(changed, removed)
    :ok
  end
end
