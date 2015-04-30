defmodule Thumbifier.Repo.Migrations.CreateApiGrant do
  use Ecto.Migration

  def change do
    create table(:api_grants) do
      add :user_email, :string
      add :api_grant, :string
      add :expires_at, :datetime
    end
  end
end
