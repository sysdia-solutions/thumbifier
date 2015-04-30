defmodule Thumbifier.Error.NotFound do
  defstruct resource: "", id: "", message: ""
end

defimpl Poison.Encoder, for: Thumbifier.Error.NotFound do
  def encode(error, _options) do
    %{message: "#{error.resource} '#{error.id}' can not be found"}
    |> Poison.Encoder.encode([])
  end
end
