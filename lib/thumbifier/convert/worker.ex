defmodule Thumbifier.Convert.Worker do
  use GenServer

  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(data, _from, state) do
    Application.get_env(:thumbifier, :max_file_size)
    |> Thumbifier.Convert.Processor.process(data)
    {:reply, [], state}
  end
end
