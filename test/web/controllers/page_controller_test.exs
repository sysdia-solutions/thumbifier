defmodule Thumbifier.PageControllerTest do
  use Thumbifier.ConnCase, async: false
  import Mock

  setup do
    user_luke_skywalker =
    %Thumbifier.User{
      email: "Luke@Skywalker.com",
      api_key: "key" |> Thumbifier.User.hash,
      usage_limit: 10,
      usage_counter: 0,
      usage_reset_at: Thumbifier.Util.Time.ecto_now,
      total_usage: 0
    }
    |> Thumbifier.Repo.insert

    user_boba_fett =
    %Thumbifier.User{
      email: "Boba@Fett.com",
      api_key: "key" |> Thumbifier.User.hash,
      usage_limit: 10,
      usage_counter: 10,
      usage_reset_at: Thumbifier.Util.Time.ecto_now,
      total_usage: 0
    }
    |> Thumbifier.Repo.insert

    user_han_solo =
    %Thumbifier.User{
      email: "han@solo.com",
      api_key: "key" |> Thumbifier.User.hash,
      usage_limit: 10,
      usage_counter: 10,
      usage_reset_at: Thumbifier.Util.Time.ecto_now |> Thumbifier.Util.Time.ecto_shift(mins: -15),
      total_usage: 0
    }
    |> Thumbifier.Repo.insert

    access_token_luke_skywalker = %Thumbifier.AccessToken{user_email: user_luke_skywalker.email, access_token: "jedi"}
                               |>Thumbifier.Repo.insert

    access_token_boba_fett = %Thumbifier.AccessToken{user_email: user_boba_fett.email, access_token: "bounty_hunter"}
                          |>Thumbifier.Repo.insert

    access_token_han_solo = %Thumbifier.AccessToken{user_email: user_han_solo.email, access_token: "smuggler"}
                         |>Thumbifier.Repo.insert

    expired_time = Thumbifier.Util.Time.ecto_now |> Thumbifier.Util.Time.ecto_shift(mins: -10)
    access_token_darth_maul = %Thumbifier.AccessToken{user_email: "darth@maul.com", access_token: "dead_sith", expires_at: expired_time}
                         |>Thumbifier.Repo.insert

    {:ok,
      user_luke_skywalker: user_luke_skywalker,
      user_boba_fett: user_boba_fett,
      user_han_solo: user_han_solo,
      access_token_luke_skywalker: access_token_luke_skywalker,
      access_token_boba_fett: access_token_boba_fett,
      access_token_han_solo: access_token_han_solo,
      access_token_darth_maul: access_token_darth_maul
    }
  end

  defp send_request(conn) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> Thumbifier.Endpoint.call([])
  end

  test "/create returns unauthorized when an invalid access_token is provided" do
    data = %{
      "access_token" => "invalid",
      "media_url" => "http://www.testurl.com",
      "callback_url" => "http://mycallback.com"
    }
    response = conn(:post, "/", data) |> send_request

    assert response.status == 401
    assert response.resp_body == %{message: "AccessToken '#{data["access_token"]}' is not authorized"} |> Poison.encode!
  end

  test "/create deletes the access_token on processing the request even on error", %{access_token_boba_fett: access_token_boba_fett} do
    data = %{
      "access_token" => access_token_boba_fett.access_token,
      "media_url" => "http://www.testurl.com",
      "callback_url" => "http://mycallback.com"
    }
    conn(:post, "/", data) |> send_request

    access_token = Thumbifier.AccessToken.find(%{access_token: data["access_token"]})

    assert access_token == nil
  end

  test "/create purges all expired access_tokens on processing the request", %{access_token_darth_maul: access_token_darth_maul} do
    data = %{
      access_token: access_token_darth_maul.access_token,
      media_url: "http://www.testurl.com",
      callback_url: "http://mycallback.com"
    }
    response = conn(:post, "/", data) |> send_request

    access_token = Thumbifier.AccessToken.find(%{access_token: data.access_token})

    assert access_token == nil

    assert response.status == 401
    assert response.resp_body == %{message: "AccessToken '#{data.access_token}' is not authorized"} |> Poison.encode!
  end

  test "/create returns too_many_requests when usage limit is exceeded", %{access_token_boba_fett: access_token_boba_fett}  do
    data = %{
      "access_token" => access_token_boba_fett.access_token,
      "media_url" => "http://www.testurl.com",
      "callback_url" => "http://mycallback.com"
    }
    response = conn(:post, "/", data) |> send_request

    assert response.status == 429
    assert response.resp_body == %{message: "User limit exceeded - 10/10"} |> Poison.encode!
  end

  test "/create returns bad_request when an invalid media_url is provided", %{access_token_luke_skywalker: access_token_luke_skywalker} do
    data = %{
      "access_token" => access_token_luke_skywalker.access_token,
      "media_url" => "bad url",
      "callback_url" => "http://mycallback.com"
    }
    response = conn(:post, "/", data) |> send_request

    assert response.status == 400
    assert response.resp_body == %{message: "Request 'bad url' is invalid"} |> Poison.encode!
  end

  test "/create returns process id when a successful job is created", %{access_token_luke_skywalker: access_token_luke_skywalker} do
    with_mock Thumbifier.Convert.Dispatcher, [dispatch: fn(_opts) -> :ok end] do
      data = %{
        "access_token" => access_token_luke_skywalker.access_token,
        "callback_url" => "http://mycallback.com",
        "quality" => "72",
        "dimensions" => "100x100",
        "format" => "json",
        "frame" => "1",
        "media_url" => "https://github.com/sysdia/thumbifier/raw/master/test/fixtures/files/pdf.pdf",
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

  test "/create resets the user's usage_counter if the time limit has expired", %{user_han_solo: user_han_solo, access_token_han_solo: access_token_han_solo} do
    with_mock Thumbifier.Convert.Dispatcher, [dispatch: fn(_opts) -> :ok end] do
      data = %{
        "access_token" => access_token_han_solo.access_token,
        "callback_url" => "http://mycallback.com",
        "quality" => "72",
        "dimensions" => "100x100",
        "format" => "json",
        "frame" => "1",
        "media_url" => "https://github.com/sysdia/thumbifier/raw/master/test/fixtures/files/pdf.pdf",
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

  test "GET / displays a JSON array of supported mime-types" do
    response = conn(:get, "/") |> send_request
    assert response.resp_body |> Poison.decode! == Thumbifier.Convert.Types.all
  end

  test "GET /:type displays JSON true or false if given mime-type is supported" do
    response = conn(:get, "/application_pdf") |> send_request
    assert response.resp_body |> Poison.decode! == true

    response = conn(:get, "/image_iff") |> send_request
    assert response.resp_body |> Poison.decode! == false
  end
end
