defmodule Thumbifier.Plug.Authenticated do
  @moduledoc """
  Plug that protects routes from unauthenticated access.
  """
  import Plug.Conn
  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    email =  Map.get(conn.params, "email")
    api_token = get_req_header(conn, "Authorization")

    case check_token(email, api_token) do
      {:ok, user} -> assign(conn, :user, user)
      {:error, message} -> send_resp(conn, :unauthorized, Poison.encode!(%{error: message}))
      |> halt
    end
  end

  defp check_token(email, ["Bearer " <> token]) do
    case Thumbifier.User.find(%{email: email, api_token: token}) do
      nil -> check_token(:error, :error)
      user -> {:ok, user}
    end
  end

  defp check_token(_email, _token) do
    {:error, "Not Authorized"}
  end
end
