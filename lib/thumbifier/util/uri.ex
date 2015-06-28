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
  HTTP POST the given data map to the provided uri
  """
  def post(data, uri) do
    HTTPoison.post(uri, data)
  end

  @doc """
  Return the type and file size of the given URI
  """
  def details(uri) do
    valid?(uri)
    |> details_response(uri)
  end

  @doc """
  Download a remote uri and save to the given local save location
  """
  def download(uri, save_to) do
    valid?(uri)
    |> download_response(uri, save_to)
  end

  defp download_response(false, uri, _save_to) do
    {:error, uri <> " is not a valid URI"}
  end

  defp download_response(true, uri, save_to) do
    Thumbifier.Util.Shell.wget(uri, save_to)
    {:ok, save_to}
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
    if results == nil do
      0
    else
      List.last(results) |> String.to_integer
    end
  end
end
