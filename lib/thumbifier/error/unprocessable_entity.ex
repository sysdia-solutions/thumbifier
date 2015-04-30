defmodule Thumbifier.Error.UnprocessableEntity do
  defstruct resource: "", message: ""
end

defimpl Poison.Encoder, for: Thumbifier.Error.UnprocessableEntity do
  def encode(error, _options) do
    %{message: error.message
      |> merge_error_keys
    }
    |> Poison.Encoder.encode([])
  end

  defp merge_error_keys(errors) do
    Enum.reduce(errors, %{}, fn({k, v}, acc ) ->
      Map.update(acc, k, [v], &[v|&1])
    end)
  end
end
