defmodule Thumbifier.User do
  use Thumbifier.Web, :model

  schema "users" do
    field :email, :string
    field :api_token, :string
    field :usage_limit, :integer, default: 10
    field :usage_counter, :integer, default: 0
    field :usage_reset_at, Ecto.DateTime
    field :total_usage, :integer, default: 0

    timestamps
  end

  @required_fields ~w(email api_token usage_limit usage_counter usage_reset_at total_usage)
  @optional_fields ~w()

  def find(%{email: email, api_token: api_token}) do
    query = from u in Thumbifier.User,
            where: u.email == ^email and u.api_token == ^hash(api_token)
    Thumbifier.Repo.one(query)
  end

  def find(%{email: email}) do
    query = from u in Thumbifier.User,
            where: u.email == ^email
    Thumbifier.Repo.one(query)
  end

  def new(%{email: email}) do
    api_token = Ecto.UUID.generate
    usage_reset_at = Thumbifier.Util.Time.ecto_now
    new_user = %{
                 %Thumbifier.User{} |
                 email: email,
                 api_token: api_token
                            |> hash,
                 usage_reset_at: usage_reset_at
                }
                |> Map.from_struct

    changeset = Thumbifier.User.changeset(%Thumbifier.User{}, new_user)
    persist(changeset.valid?, changeset, :insert, %{email: email, api_token: api_token})
  end

  def delete(%{email: email}) do
    find(%{email: email})
    |> remove
  end

  @doc """
  Check if the user has enough usage credits in the current reset cycle
  """
  def under_usage_limit?(user = %Thumbifier.User{}) do
    user = usage_cycle_expired?(user) |> reset_usage_cycle(user)
    user.usage_counter < user.usage_limit
  end

  def under_usage_limit?(nil) do
    false
  end

  @doc """
  Increase the given User's `usage_counter` by 1
  """
  def update_usage_counter(user = %Thumbifier.User{}) do
    user = Thumbifier.User.find(%{email: user.email})
    update_with = %{ user | usage_counter: user.usage_counter + 1, total_usage: user.total_usage + 1}
    update(user, update_with)
  end

  @doc """
  Update the given User's `email` with the provided `new_email`
  """
  def update_email(user = %Thumbifier.User{}, %{new_email: new_email}) do
    update_with = %{ user | email: new_email }
    update(user, update_with)
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_unique(:email, on: Thumbifier.Repo)
  end

  def hash(string) do
    :crypto.hash(:sha512, string)
    |> Base.encode16
  end

  defp update(user = %Thumbifier.User{}, update_with = %Thumbifier.User{}) do
    changeset = Thumbifier.User.changeset(user, update_with |> Map.from_struct)
    persist(changeset.valid?, changeset, :update, %{})
  end

  defp persist(false, changeset, _type, _options) do
    %{error: changeset.errors}
  end

  defp persist(true, changeset, :insert, options) do
    Thumbifier.Repo.insert(changeset)
    %{email: options.email, api_token: options.api_token}
  end

  defp persist(true, changeset, :update, _options) do
    Thumbifier.Repo.update(changeset)
    find(%{email: get_change(changeset, :email, changeset.model.email)})
  end

  defp remove(user = %Thumbifier.User{}) do
    Thumbifier.Repo.delete(user)
    true
  end

  defp remove(nil) do
    false
  end

  defp usage_cycle_expired?(user) do
    reset_at = user.usage_reset_at
    reset_trigger = Thumbifier.Util.Time.ecto_now
                    |> Thumbifier.Util.Time.ecto_shift(mins: -10)
    reset_trigger >= reset_at
  end

  defp reset_usage_cycle(false, user) do
    user
  end

  defp reset_usage_cycle(true, user) do
    update_with = %{ user | usage_counter: 0, usage_reset_at: Thumbifier.Util.Time.ecto_now}
    update(user, update_with)
  end
end
