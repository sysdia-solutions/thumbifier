defmodule Thumbifier.PageControllerTest do
  use Thumbifier.ConnCase, async: false
  import Mock

  setup do
    user_luke_skywalker =
    %Thumbifier.User{
      email: "Luke@Skywalker.com",
      api_token: "token" |> Thumbifier.User.hash,
      usage_limit: 10,
      usage_counter: 0,
      usage_reset_at: Thumbifier.Util.Time.ecto_now,
      total_usage: 0
    }
    |> Thumbifier.Repo.insert

    user_boba_fett =
    %Thumbifier.User{
      email: "Boba@Fett.com",
      api_token: "token" |> Thumbifier.User.hash,
      usage_limit: 10,
      usage_counter: 10,
      usage_reset_at: Thumbifier.Util.Time.ecto_now,
      total_usage: 0
    }
    |> Thumbifier.Repo.insert

    user_han_solo =
    %Thumbifier.User{
      email: "han@solo.com",
      api_token: "token" |> Thumbifier.User.hash,
      usage_limit: 10,
      usage_counter: 10,
      usage_reset_at: Thumbifier.Util.Time.ecto_now |> Thumbifier.Util.Time.ecto_shift(mins: -15),
      total_usage: 0
    }
    |> Thumbifier.Repo.insert

    api_grant_luke_skywalker = %Thumbifier.ApiGrant{user_email: user_luke_skywalker.email, api_grant: "jedi"}
                               |>Thumbifier.Repo.insert

    api_grant_boba_fett = %Thumbifier.ApiGrant{user_email: user_boba_fett.email, api_grant: "bounty_hunter"}
                          |>Thumbifier.Repo.insert

    api_grant_han_solo = %Thumbifier.ApiGrant{user_email: user_han_solo.email, api_grant: "smuggler"}
                         |>Thumbifier.Repo.insert

    expired_time = Thumbifier.Util.Time.ecto_now |> Thumbifier.Util.Time.ecto_shift(mins: -10)
    api_grant_darth_maul = %Thumbifier.ApiGrant{user_email: "darth@maul.com", api_grant: "dead_sith", expires_at: expired_time}
                         |>Thumbifier.Repo.insert

    {:ok,
      user_luke_skywalker: user_luke_skywalker,
      user_boba_fett: user_boba_fett,
      user_han_solo: user_han_solo,
      api_grant_luke_skywalker: api_grant_luke_skywalker,
      api_grant_boba_fett: api_grant_boba_fett,
      api_grant_han_solo: api_grant_han_solo,
      api_grant_darth_maul: api_grant_darth_maul
    }
  end

  defp send_request(conn) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> Thumbifier.Endpoint.call([])
  end

  test "/create returns unauthorized when an invalid api_grant is provided" do
    data = %{
      "api_grant" => "invalid",
      "media_url" => "http://www.testurl.com",
      "callback_url" => "http://mycallback.com"
    }
    response = conn(:post, "/", data) |> send_request

    assert response.status == 401
    assert response.resp_body == %{message: "Grant '#{data["api_grant"]}' is not authorized"} |> Poison.encode!
  end

  test "/create deletes the api_grant on processing the request even on error", %{api_grant_boba_fett: api_grant_boba_fett} do
    data = %{
      "api_grant" => api_grant_boba_fett.api_grant,
      "media_url" => "http://www.testurl.com",
      "callback_url" => "http://mycallback.com"
    }
    conn(:post, "/", data) |> send_request

    api_grant = Thumbifier.ApiGrant.find(%{api_grant: data["api_grant"]})

    assert api_grant == nil
  end

  test "/create purges all expired api grants on processing the request", %{api_grant_darth_maul: api_grant_darth_maul} do
    data = %{
      api_grant: api_grant_darth_maul.api_grant,
      media_url: "http://www.testurl.com",
      callback_url: "http://mycallback.com"
    }
    response = conn(:post, "/", data) |> send_request

    api_grant = Thumbifier.ApiGrant.find(%{api_grant: data.api_grant})

    assert api_grant == nil

    assert response.status == 401
    assert response.resp_body == %{message: "Grant '#{data.api_grant}' is not authorized"} |> Poison.encode!
  end

  test "/create returns too_many_requests when usage limit is exceeded", %{api_grant_boba_fett: api_grant_boba_fett}  do
    data = %{
      "api_grant" => api_grant_boba_fett.api_grant,
      "media_url" => "http://www.testurl.com",
      "callback_url" => "http://mycallback.com"
    }
    response = conn(:post, "/", data) |> send_request

    assert response.status == 429
    assert response.resp_body == %{message: "User limit exceeded - 10/10"} |> Poison.encode!
  end

  test "/create returns bad_request when an invalid media_url is provided", %{api_grant_luke_skywalker: api_grant_luke_skywalker} do
    data = %{
      "api_grant" => api_grant_luke_skywalker.api_grant,
      "media_url" => "bad url",
      "callback_url" => "http://mycallback.com"
    }
    response = conn(:post, "/", data) |> send_request

    assert response.status == 400
    assert response.resp_body == %{message: "Request 'bad url' is invalid"} |> Poison.encode!
  end

  test "/create returns process id when a successful job is created", %{api_grant_luke_skywalker: api_grant_luke_skywalker} do
    with_mock Thumbifier.Convert.Dispatcher, [dispatch: fn(_opts) -> :ok end] do
      data = %{
        "api_grant" => api_grant_luke_skywalker.api_grant,
        "callback_url" => "http://mycallback.com",
        "quality" => "72",
        "dimensions" => "100x100",
        "format" => "json",
        "frame" => "1",
        "media_url" => "http://www.pdf995.com/samples/pdf.pdf",
        "page" => "1",
        "personal_reference" => "",
        "response_id" => "c6f05692-e293-411d-a1bd-d44918746838"
      }
      response = conn(:post, "/", data) |> send_request

      assert called Thumbifier.Convert.Dispatcher.dispatch(data)

      body = response.resp_body |> Poison.decode!

      assert response.status == 201
      assert String.length(body) == 36
    end
  end

  test "/create resets the user's usage_counter if the time limit has expired", %{user_han_solo: user_han_solo, api_grant_han_solo: api_grant_han_solo} do
    with_mock Thumbifier.Convert.Dispatcher, [dispatch: fn(_opts) -> :ok end] do
      data = %{
        "api_grant" => api_grant_han_solo.api_grant,
        "callback_url" => "http://mycallback.com",
        "quality" => "72",
        "dimensions" => "100x100",
        "format" => "json",
        "frame" => "1",
        "media_url" => "http://www.pdf995.com/samples/pdf.pdf",
        "page" => "1",
        "personal_reference" => "",
        "response_id" => "c6f05692-e293-411d-a1bd-d44918746838"
      }

      check_user = Thumbifier.User.find(%{email: user_han_solo.email})
      assert check_user.usage_counter == 10

      response = conn(:post, "/", data) |> send_request

      assert called Thumbifier.Convert.Dispatcher.dispatch(data)

      body = response.resp_body |> Poison.decode!

      assert response.status == 201
      assert String.length(body) == 36

      check_user = Thumbifier.User.find(%{email: user_han_solo.email})
      assert check_user.usage_counter == 1
    end
  end
end
