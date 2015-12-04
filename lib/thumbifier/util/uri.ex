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
    |> file_details(uri)
  end

  @doc """
  Download a remote uri and save to the given local save location
  """
  def download(uri, save_to) do
    valid?(uri)
    |> file_download(uri, save_to)
  end

  defp file_download(false, uri, _save_to) do
    {:error, uri <> " is not a valid URI"}
  end

  defp file_download(true, uri, save_to) do
    Thumbifier.Util.Shell.wget(uri, save_to)
    |> download_response(save_to)
  end

  defp download_response({:error, message}, _save_to) do
    {:error, message}
  end

  defp download_response(_results, save_to) do
    {:ok, save_to}
  end

  defp file_details(false, uri) do
    {:error, uri <> " is not a valid URI"}
  end

  defp file_details(true, uri) do
    Thumbifier.Util.Shell.wget(uri)
    |> details_response()
  end

  defp details_response({:error, message}) do
    {:error, message}
  end

  defp details_response(results) do
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
