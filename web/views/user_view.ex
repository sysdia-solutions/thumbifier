defimpl Poison.Encoder, for: Thumbifier.User do
  def encode(user, _options) do
    %{
      email: user.email,
      api_grant: user.api_token,
      usage_limit: user.usage_limit,
      usage_counter: user.usage_counter,
      usage_reset_at: user.usage_reset_at,
      total_usage: user.total_usage
    } |> Poison.Encoder.encode([])
  end
end

defmodule Thumbifier.UserView do
  use Thumbifier.Web, :view

  def render("show.json", %{user: user, api_grant: api_grant}) do
    %{ user | api_token: api_grant.api_grant }
  end

  def render("show.json", %{error: error}) do
    error
  end
end
