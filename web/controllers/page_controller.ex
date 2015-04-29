defmodule Thumbifier.PageController do
  use Thumbifier.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
