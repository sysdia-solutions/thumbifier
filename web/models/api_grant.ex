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
end
