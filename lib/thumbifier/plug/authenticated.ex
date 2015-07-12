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
    api_key = get_req_header(conn, "authorization")

    case check_key(email, api_key) do
      {:ok, user} -> assign(conn, :user, user)
      {:error, message} -> send_resp(conn, :unauthorized, Poison.encode!(%{error: message}))
      |> halt
    end
  end

  defp check_key(email, ["Bearer " <> key]) do
    case Thumbifier.User.find(%{email: email, api_key: key}) do
      nil -> check_key(:error, :error)
      user -> {:ok, user}
    end
  end

  defp check_key(_email, _key) do
    {:error, "Not Authorized"}
  end
end
