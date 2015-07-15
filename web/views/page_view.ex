defmodule Thumbifier.PageView do
  use Thumbifier.Web, :view

  def render("create.json", %{error: error}) do
    error
  end

  def render("create.json", %{ok: response_id}) do
    response_id
  end

  def render("list.json", %{ok: data}) do
    data
  end

  def render("show.json", %{ok: result}) do
    result
  end
end
