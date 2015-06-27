defmodule Thumbifier.Util.File do
  def mime_type(file_path) do
    if File.exists?(file_path) do
      mime_type = Thumbifier.Util.Shell.file_mime_type(file_path)
      |> format_mime_type
      {:ok, mime_type}
    else
      {:error, file_path <> " file not found"}
    end
  end

  defp format_mime_type(mime_type) do
    String.strip(mime_type)
  end
end
