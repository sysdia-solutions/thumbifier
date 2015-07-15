defmodule Thumbifier.PageController do
  use Thumbifier.Web, :controller

  plug :action

  def list(conn, _params) do
    conn
    |> render(ok: Thumbifier.Convert.Types.all)
  end

  def show(conn, %{"type" => type}) do
    conn
    |> render(ok: Thumbifier.Convert.Types.is_supported?(type |> String.replace("_", "/")))
  end

  def create(conn, params) do
    post_optional_params = %{"personal_reference" => "", "quality" => "72", "dimensions" => "100x100", "page" => "1", "frame" => "1"}

    params = Map.merge(post_optional_params, params)
    create_check_access_token(conn, params)
  end

  defp create_check_access_token(conn, params) do
    Thumbifier.AccessToken.purge()
    Thumbifier.AccessToken.find(%{access_token: params["access_token"]})
    |> create_check_limit(conn, params)
  end

  defp create_check_limit(nil, conn, params) do
    conn
    |> put_status(:unauthorized)
    |> render(error: %Thumbifier.Error.Unauthorized{resource: "AccessToken", id: params["access_token"]})
  end

  defp create_check_limit(access_token = %Thumbifier.AccessToken{}, conn, params) do
    Thumbifier.AccessToken.delete(%{access_token: access_token.access_token})

    user = Thumbifier.User.find(%{email: access_token.user_email})
    Thumbifier.User.under_usage_limit?(user)
    |> create_validate_url(conn, params, user)
  end

  defp create_validate_url(false, conn, _params, user) do
    conn
    |> put_status(:too_many_requests)
    |> render(error: %Thumbifier.Error.TooManyRequests{resource: "User", id: to_string(user.usage_counter) <> "/" <> to_string(user.usage_limit)})
  end

  defp create_validate_url(true, conn, params, user) do
    Thumbifier.Util.URI.valid?(params["media_url"])
    |> create_process(conn, params, user)
  end

  defp create_process(false, conn, params, _user) do
    conn
    |> put_status(:bad_request)
    |> render(error: %Thumbifier.Error.BadRequest{resource: "Request", id: params["media_url"]})
  end

  defp create_process(true, conn, params, user) do
    params = Map.merge(%{"response_id" => Ecto.UUID.generate}, params)

    Thumbifier.User.update_usage_counter(user)
    Thumbifier.Convert.Dispatcher.dispatch(params)

    conn
    |> put_status(:created)
    |> render(ok: params["response_id"])
  end
end
