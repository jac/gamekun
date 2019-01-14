defmodule GameKun.Application do
  use Application

  def start(_type, rom_path) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: GameKun.Worker.start_link(arg)
      # {GameKun.Worker, arg},
      {GameKun.Cart, rom_path}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: GameKun.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
