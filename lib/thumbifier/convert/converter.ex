defmodule Thumbifier.Convert.Converter do
  @doc """
  Call ImageMagick convert function on given file to convert to jpg and resize
  """
  def resize(file, quality, size) do
    Regex.replace(~r/\[[0-9]+\]/, file, "")
    |> File.exists?
    |> resize_response(file, quality, size)
  end

  @doc """
  Convert a PDF to a jpg
  """
  def from_pdf(file, quality, size, page) do
    if !is_integer(page) do
      page = page |> Integer.parse |> elem(0)
    end
    "#{file}[#{page - 1}]"
    |> resize(quality, size)
  end

  @doc """
  Convert a PSD to a jpg
  """
  def from_psd(file, quality, size, page) do
    from_pdf(file, quality, size, page)
  end

  @doc """
  Convert a video file frame to a jpg
  """
  def from_video(file, quality, size, frame) do
    if frame == "auto" do
      frame = "00:00:01"
    end

    output_dir =  System.tmp_dir! <> "/video-convert-" <> Ecto.UUID.generate <> "/"
    File.mkdir(output_dir)
    output_file = output_dir <> "video.jpg"

    ["-i", file, "-ss", frame, "-vframes", "1", output_file]
    |> Thumbifier.Util.Shell.ffmpeg
    jpg = resize(output_file, quality, size)

    File.rm_rf(output_dir)

    jpg
  end

  @doc """
  Convert a Website to a jpg
  """
  def from_website(url, quality, size) do
    output_dir =  System.tmp_dir! <> "/website-convert-" <> Ecto.UUID.generate <> "/"
    File.mkdir(output_dir)
    output_file = output_dir <> "website.pdf"

    ["--disable-smart-shrinking", "--page-width", "508mm", "--page-height", "285mm", url, output_file]
    |> Thumbifier.Util.Shell.wkhtmltopdf

    jpg = from_pdf(output_file, quality, size, 1)

    File.rm_rf(output_dir)

    jpg
  end

  def from_document(file, quality, size, page) do
    from_office(file, quality, size, page)
  end

  def from_spreadsheet(file, quality, size, page) do
    from_office(file, quality, size, page)
  end

  def from_presentation(file, quality, size, page) do
    from_office(file, quality, size, page)
  end

  def from_office(file, quality, size, page) do
    output_dir =  System.tmp_dir! <> "/office-convert-" <> Ecto.UUID.generate <> "/"
    File.mkdir(output_dir)
    output_file = output_dir <> "office.pdf"

    ["-f", "pdf", "-o", output_file, file]
    |> Thumbifier.Util.Shell.unoconv

    jpg = from_pdf(output_file, quality, size, page)

    File.rm_rf(output_dir)

    jpg
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
