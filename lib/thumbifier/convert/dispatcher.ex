defmodule Thumbifier.Convert.Dispatcher do
  def dispatch(data) do
    spawn( fn() -> parallel(data) end )
  end

  defp parallel(data) do
    :poolboy.transaction(
      :thumbifier,
      fn(pid) -> Thumbifier.Convert.Worker.process_job(pid, data) end,
      :infinity
    )
  end
end
