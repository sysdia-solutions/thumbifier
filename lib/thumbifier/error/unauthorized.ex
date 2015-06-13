defmodule Thumbifier.Error.Unauthorized do
  defstruct resource: "", id: "", message: ""
end

defimpl Poison.Encoder, for: Thumbifier.Error.Unauthorized do
  def encode(error, _options) do
    %{message: "#{error.resource} '#{error.id}' is not authorized"}
    |> Poison.Encoder.encode([])
  end
end
