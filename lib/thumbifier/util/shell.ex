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
end
