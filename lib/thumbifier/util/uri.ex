defmodule Thumbifier.Util.URI do
  @doc """
  Determine if a given string is a valid URI
  """
  def valid?(string) do
    pattern = "^(((ht|f)tp(s?))\://)?(www.|[a-zA-Z].)[a-zA-Z0-9\-\.]+\.([a-z\.])(\:[0-9]+)*(/($|[a-zA-Z0-9\.
    +\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$"

    Regex.compile(pattern)
    |> elem(1)
    |> Regex.match?(string)
  end

  @doc """
  Return the type and file size of the given URI
  """
  def details(uri) do
    valid?(uri)
    |> details_response(uri)
  end

  defp details_response(false, uri) do
    {:error, uri <> " is not a valid URI"}
  end

  defp details_response(true, uri) do
    results = Thumbifier.Util.Shell.wget(uri)
    {:ok, size: uri_size(results), type: uri_type(results)}
  end

  defp uri_type(data) do
    type = :invalid

    if String.contains?(data, "\nRemote file exists.") do
      type = :file
    end

    if String.contains?(data, "\nRemote file exists and could contain further links") do
      type = :site
    end

    type
  end

  defp uri_size(data) do
    results = Regex.run(~r/.*Length:\s(.*)\s\(/, data)
    List.last(results) |> String.to_integer
  end
end
