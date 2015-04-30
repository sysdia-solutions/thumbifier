defmodule UserControllerTest do
  use Thumbifier.ConnCase

  setup do
    token = "rebel"
    user =
      %Thumbifier.User{
        email: "Luke@Skywalker.com",
        api_token: token |> Thumbifier.User.hash,
        usage_limit: 0,
        usage_counter: 0,
        usage_reset_at: nil,
        total_usage: 0
      }
      |> Thumbifier.Repo.insert

    {:ok, user: user, token: token}
  end

  defp send_request(conn) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> Thumbifier.Endpoint.call([])
  end

  defp add_auth_header(conn, secret) do
    put_req_header(conn, "authorization", "Bearer #{secret}")
  end

  test "/show returns unauthorized when no api_token is supplied", %{user: user} do
    response = conn(:get, "/users/#{user.email}") |> send_request
    assert response.status == 401
    assert response.resp_body == %{error: "Not Authorized"} |> Poison.encode!
  end

  test "/show returns unauthorized when an invalid api_token is supplied", %{user: user} do
    response = conn(:get, "/users/#{user.email}")
               |> add_auth_header("sith")
               |> send_request
    assert response.status == 401
    assert response.resp_body == %{error: "Not Authorized"} |> Poison.encode!
  end

  test "/show returns unauthorized when an invalid email is supplied", %{token: token} do
    invalid_email = "Darth@Vadar.com"

    response = conn(:get, "/users/#{invalid_email}")
               |> add_auth_header(token)
               |> send_request
    assert response.status == 401
    assert response.resp_body == %{error: "Not Authorized"} |> Poison.encode!
  end

  test "/show returns unauthorized when an invalid email and api_token are supplied" do
    invalid_email = "Darth@Vadar.com"

    response = conn(:get, "/users/#{invalid_email}")
               |> add_auth_header("sith")
               |> send_request
    assert response.status == 401
    assert response.resp_body == %{error: "Not Authorized"} |> Poison.encode!
  end

  test "/show returns a user when a valid email and api_token are supplied", %{user: user, token: token} do
    user_as_json = user |> Poison.encode!

    response = conn(:get, "/users/#{user.email}")
               |> add_auth_header(token)
               |> send_request
    assert response.status == 200
    assert response.resp_body == user_as_json
  end
end
