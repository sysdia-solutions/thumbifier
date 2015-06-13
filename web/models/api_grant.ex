defmodule Thumbifier.ApiGrant do
  use Thumbifier.Web, :model

  schema "api_grants" do
    field :user_email, :string
    field :api_grant, :string
    field :expires_at, Ecto.DateTime
  end

  @required_fields ~w(user_email, api_grant, expires_at)
  @optional_fields ~w()

  def generate() do
    Ecto.UUID.generate
  end

  def find(%{api_grant: api_grant}) do
    query = from g in Thumbifier.ApiGrant,
            where: g.api_grant == ^api_grant
    Thumbifier.Repo.one(query)
  end

  def new(api_grant, user_email) do
    expires_at =  Thumbifier.Util.Time.ecto_now
                  |> Thumbifier.Util.Time.ecto_shift(mins: 10)
    %Thumbifier.ApiGrant{ user_email: user_email, api_grant: api_grant, expires_at: expires_at }
    |> Thumbifier.Repo.insert

    %{api_grant: api_grant}
  end

  def delete(%{api_grant: api_grant}) do
    find(%{api_grant: api_grant})
    |> remove
  end

  @doc """
  Delete all ApiGrants that have exeeced the expiry time
  """
  def purge() do
    now = Thumbifier.Util.Time.ecto_now
    query = from g in Thumbifier.ApiGrant,
            where: g.expires_at <= ^now
    Thumbifier.Repo.delete_all(query)
  end

  @doc """
  Delete all ApiGrants for the given user_email
  """
  def purge(%{user_email: user_email}) do
    query = from g in Thumbifier.ApiGrant,
            where: g.user_email == ^user_email
    Thumbifier.Repo.delete_all(query)
  end

  defp remove(api_grant = %Thumbifier.ApiGrant{}) do
    Thumbifier.Repo.delete(api_grant)
    true
  end

  defp remove(nil) do
    false
  end
end
