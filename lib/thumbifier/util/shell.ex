defmodule Thumbifier.Util.Shell do
  @doc """
  Return the type and file size of the given URI
  """
  def wget(uri) do
    Sh.wget "--spider", "-v", uri
  end
end
