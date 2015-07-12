defimpl Poison.Encoder, for: Thumbifier.User do
  def encode(user, _options) do
    %{
      email: user.email,
      access_token: user.api_key,
      usage_limit: user.usage_limit,
      usage_counter: user.usage_counter,
      usage_reset_at: user.usage_reset_at,
      total_usage: user.total_usage
    } |> Poison.Encoder.encode([])
  end
end

defmodule Thumbifier.UserView do
  use Thumbifier.Web, :view

  def render("show.json", %{user: user, access_token: access_token}) do
    %{ user | api_key: access_token.access_token }
  end

  def render("show.json", %{error: error}) do
    error
  end

  def render("create.json", %{user: user}) do
    user
  end

  def render("create.json", %{error: error}) do
    error
  end

  def render("delete.json", %{error: error}) do
    error
  end

  def render("delete.json", _params) do
  end

  def render("update.json", %{error: error}) do
    error
  end

  def render("update.json", %{user: user}) do
    user
  end
end
