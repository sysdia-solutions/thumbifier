defmodule Thumbifier.Error.TooManyRequests do
  defstruct resource: "", id: "", message: ""
end

defimpl Poison.Encoder, for: Thumbifier.Error.TooManyRequests do
  def encode(error, _options) do
    %{message: "#{error.resource} limit exceeded - #{error.id}"}
    |> Poison.Encoder.encode([])
  end
end
