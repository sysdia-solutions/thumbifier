defmodule Thumbifier.Util.Validation do
  def uri(string) do
    uri = URI.parse(string)
    case uri do
      %URI{host: nil} -> false
      _uri -> true
    end
  end
end
