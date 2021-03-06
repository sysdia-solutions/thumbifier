require Logger

defmodule Thumbifier.UserController do
  use Thumbifier.Web, :controller

  def show(conn, %{"email" => email}) do
    Logger.debug("Showing details for user #{ email}")
    Thumbifier.User.find(%{email: email})
    |> show_response(conn, email)
  end

  def create(conn, %{ "email" => email }) do
    Logger.info("Creating user for email #{ email }")
    Thumbifier.User.new(%{email: email})
    |> create_response(conn, email)
  end

  def delete(conn, %{ "email" => email }) do
    Logger.info("Deleting user for email #{ email }")
    Thumbifier.User.delete(%{email: email})
    |> delete_response(conn, email)
  end

  def update(conn, %{ "email" => email, "new_email" => new_email }) do
    Logger.info("Updating user for email #{ email }")
    Thumbifier.User.find(%{email: email})
    |> update_email(conn, email, new_email)
  end

  defp update_email(user = %Thumbifier.User{}, conn, current_email, new_email) do
    Logger.info("Updating user: old email = #{ current_email } / new email = #{ new_email }")
    Thumbifier.User.update_email(user, %{new_email: new_email})
    |> update_email_response(conn, current_email, new_email)
  end

  defp update_email(nil, conn, current_email, _new_email) do
    Logger.warn("Failed updating user email for #{ current_email } - User not found")
    conn
    |> put_status(:not_found)
    |> render(error: not_found_error("User", current_email))
  end

  defp update_email_response(user = %Thumbifier.User{}, conn, previous_email, _new_email) do
    Logger.info("Updated user email successfully")
    user = %{previous_email: previous_email, current_email: user.email}
    conn
    |> put_status(:ok)
    |> render(user: user)
  end

  defp update_email_response(%{ error: error }, conn, _previous_email, _new_email) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(error: unprocessable_entity_error("User", error))
  end

  defp delete_response(true, conn, email) do
    Logger.info("Deleted user successfully")
    Thumbifier.AccessToken.purge(%{user_email: email})
    conn
    |> put_status(:no_content)
    |> render()
  end

  defp delete_response(false, conn, email) do
    Logger.warn("Failed deleting user #{ email } - User not found")
    conn
    |> put_status(:not_found)
    |> render(error: not_found_error("User", email))
  end

  defp create_response(%{ api_key: key}, conn, email) do
    user = %{email: email, api_key: key}

    Application.get_env(:thumbifier, Thumbifier.Util.Email)
    |> Keyword.get(:from)
    |> Thumbifier.Messenger.account_created(email, key)

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
    conn
    |> render(user: user, access_token: Thumbifier.AccessToken.generate
    |> Thumbifier.AccessToken.new(user.email))
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
