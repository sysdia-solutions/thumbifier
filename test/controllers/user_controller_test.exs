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
        usage_reset_at: Thumbifier.Util.Time.ecto_now,
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
    response = conn(:get, "/users/#{user.email}")
               |> add_auth_header(token)
               |> send_request
    assert response.status == 200

    #Update the initial user's api_grant as it will always be random from the response
    user_as_json = %{ user | api_token: Map.get(response.resp_body |> Poison.decode!, "api_grant") } |> Poison.encode!
    assert response.resp_body == user_as_json
  end

  test "/create returns a user when a valid email is supplied" do
    valid_email = "yoda@theforce.com"
    response = conn(:post, "/users", %{email: valid_email}) |> send_request
    body = response.resp_body |> Poison.decode!

    assert response.status == 201
    assert body["email"] == valid_email
    assert body["api_token"] |> String.length == 36
  end

  test "/create returns unprocessable entity when an invalid email is supplied" do
    invalid_email = "jajabinks"
    response = conn(:post, "/users", %{email: invalid_email}) |> send_request
    expected_response = %{"message" => %{"email" => ["has invalid format"]}} |> Poison.encode!

    assert response.status == 422
    assert response.resp_body == expected_response
  end

  test "/create returns unprocessable entity when a duplicate email is supplied", %{user: user} do
    response = conn(:post, "/users", %{email: user.email}) |> send_request
    expected_response = %{"message" => %{"email" => ["has already been taken"]}} |> Poison.encode!

    assert response.status == 422
    assert response.resp_body == expected_response
  end
end
