defmodule UserControllerTest do
  use Thumbifier.ConnCase

  setup do
    user =
      %Thumbifier.User{
        email: "Luke@Skywalker.com",
        api_token: "rebel",
        usage_limit: 0,
        usage_counter: 0,
        usage_reset_at: nil,
        total_usage: 0
      }
      |> Thumbifier.Repo.insert

    {:ok, user: user}
  end

  defp send_request(conn) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> Thumbifier.Endpoint.call([])
  end

  test "/show returns a user when an email for a valid user is supplied", %{user: user} do
    user_as_json = user |> Poison.encode!

    response = conn(:get, "/users/#{user.email}") |> send_request

    assert response.status == 200
    assert response.resp_body == user_as_json
  end

  test "/show returns returns a 404 when an email for a missing user is supplied" do
    email = "darth@vadar.com"
    error_json = %Thumbifier.Error.NotFound{resource: "User", id: email} |> Poison.encode!
    response = conn(:get, "/users/#{email}") |> send_request

    assert response.status == 404
    assert response.resp_body == error_json
  end
end
