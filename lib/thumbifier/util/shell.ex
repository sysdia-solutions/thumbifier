defmodule Thumbifier.Util.Shell do
  @doc """
  Return the type and file size of the given URI
  """
  def wget(uri) do
    Sh.wget "--spider", "-v", uri
  end

  @doc """
  Download the given URI and save to the given path
  """
  def wget(uri, save_to) do
    Sh.wget "-O", save_to, uri
  end

  @doc """
  Display the mime_type for the given file path
  """
  def file_mime_type(file_path) do
    Sh.file "-b", "--mime-type", file_path
  end

  @doc """
  Call the ImageMagick convert command line function
  """
  def convert(params) do
    apply(Sh, :convert, params)
  end

  @doc """
  Call the ffmpeg command line function
  """
  def ffmpeg(params) do
    apply(Sh, :ffmpeg, params)
  end
end
