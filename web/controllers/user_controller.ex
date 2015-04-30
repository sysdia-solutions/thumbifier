defmodule Thumbifier.UserController do
  use Thumbifier.Web, :controller

  plug :action

  def show(conn, %{"email" => email}) do
    Thumbifier.User.find(%{email: email})
    |> show_response(conn, email)
  end

  defp show_response(user = %Thumbifier.User{}, conn, _email) do
    conn
    |> render(user: user,  api_grant: Thumbifier.ApiGrant.generate |> Thumbifier.ApiGrant.new(user.email))
  end

  defp show_response(nil, conn, email) do
    conn
    |> put_status(:not_found)
    |> render(error: not_found_error("User", email))
  end

  defp not_found_error(resource, email) do
    %Thumbifier.Error.NotFound{resource: resource, id: email}
  end
end
