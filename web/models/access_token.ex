defmodule Thumbifier.AccessToken do
  use Thumbifier.Web, :model

  schema "access_tokens" do
    field :user_email, :string
    field :access_token, :string
    field :expires_at, Ecto.DateTime
  end

  @required_fields ~w(user_email, access_token, expires_at)
  @optional_fields ~w()

  def generate() do
    Ecto.UUID.generate
  end

  def find(%{access_token: access_token}) do
    query = from g in Thumbifier.AccessToken,
            where: g.access_token == ^access_token
    Thumbifier.Repo.one(query)
  end

  def new(access_token, user_email) do
    expires_at = Thumbifier.Util.Time.ecto_now
                 |> Thumbifier.Util.Time.ecto_shift(mins: 10)
    %Thumbifier.AccessToken{ user_email: user_email, access_token: access_token, expires_at: expires_at }
    |> Thumbifier.Repo.insert

    %{access_token: access_token}
  end

  def delete(%{access_token: access_token}) do
    find(%{access_token: access_token})
    |> remove
  end

  @doc """
  Delete all AccessTokens that have exeeced the expiry time
  """
  def purge() do
    now = Thumbifier.Util.Time.ecto_now
    query = from g in Thumbifier.AccessToken,
            where: g.expires_at <= ^now
    Thumbifier.Repo.delete_all(query)
  end

  @doc """
  Delete all AccessTokens for the given user_email
  """
  def purge(%{user_email: user_email}) do
    query = from g in Thumbifier.AccessToken,
            where: g.user_email == ^user_email
    Thumbifier.Repo.delete_all(query)
  end

  defp remove(access_token = %Thumbifier.AccessToken{}) do
    Thumbifier.Repo.delete(access_token)
    true
  end

  defp remove(nil) do
    false
  end
end
