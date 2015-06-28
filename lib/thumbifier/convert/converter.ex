defmodule Thumbifier.Convert.Converter do
  @doc """
  Call ImageMagick convert function on given file to convert to jpg and resize
  """
  def resize(file, quality, size) do
    File.exists?(file)
    |> resize_response(file, quality, size)
  end

  defp resize_response(false, file, _quality, _size) do
    {:error, file <> " not found"}
  end

  defp resize_response(true, file, quality, size) do
    output =  System.tmp_dir! <> "/" <> Ecto.UUID.generate <> ".jpg"

    if is_integer(quality) do
      quality = quality |> Integer.to_string
    end

    ["-colorspace", "rgb", "-background", "white", "-flatten", "-density", quality, "-resize", size, file, output]
    |> Thumbifier.Util.Shell.convert

    {:ok, output}
  end
end
