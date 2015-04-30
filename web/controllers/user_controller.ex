defmodule Thumbifier.UserController do
  use Thumbifier.Web, :controller

  plug :action

  def show(conn, %{"email" => email}) do
    Thumbifier.User.find(%{email: email})
    |> show_response(conn, email)
  end

  def create(conn, %{ "email" => email }) do
    Thumbifier.User.new(%{email: email})
    |> create_response(conn, email)
  end

  defp create_response(%{ api_token: token}, conn, email) do
    user = %{email: email, api_token: token}
    conn
    |> put_status(:created)
    |> render(user: user)
  end

  defp create_response(%{ error: error }, conn, _email) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(error: unprocessable_entity_error("User", error))
  end

  defp show_response(user = %Thumbifier.User{}, conn, _email) do
    user = Thumbifier.User.generate_grant(user)
    conn
    |> render(user: user)
  end

  defp show_response(nil, conn, email) do
    conn
    |> put_status(:not_found)
    |> render(error: not_found_error("User", email))
  end

  defp not_found_error(resource, email) do
    %Thumbifier.Error.NotFound{resource: resource, id: email}
  end

  defp unprocessable_entity_error(resource, error) do
    %Thumbifier.Error.UnprocessableEntity{resource: resource, message: error}
  end
end
