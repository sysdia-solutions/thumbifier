defmodule Thumbifier.Convert.Dispatcher do
  def dispatch(data) do
    spawn( fn() -> parallel(data) end )
  end

  defp parallel(data) do
    :poolboy.transaction(
      :thumbifier,
      fn(pid) -> :gen_server.call(pid, data) end,
      :infinity
    )
  end
end
