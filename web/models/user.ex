defmodule Thumbifier.User do
  use Thumbifier.Web, :model

  schema "users" do
    field :email, :string
    field :api_token, :string
    field :usage_limit, :integer, default: 10
    field :usage_counter, :integer, default: 0
    field :usage_reset_at, Ecto.DateTime, default: Thumbifier.Util.Time.ecto_now
    field :total_usage, :integer, default: 0

    timestamps
  end

  @required_fields ~w(email api_token usage_limit usage_counter usage_reset_at total_usage)
  @optional_fields ~w()

  def find(%{email: email}) do
    query = from u in Thumbifier.User,
            where: u.email == ^email
    Thumbifier.Repo.one(query)
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
