defmodule Thumbifier.Error.BadRequest do
  defstruct resource: "", id: "", message: ""
end

defimpl Poison.Encoder, for: Thumbifier.Error.BadRequest do
  def encode(error, _options) do
    %{message: "#{error.resource} '#{error.id}' is invalid"}
    |> Poison.Encoder.encode([])
  end
end
