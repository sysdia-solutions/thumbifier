defmodule :"Elixir.Thumbifier.Repo.Migrations.Alter-apiGrant-to-accessToken-on-apiGrants" do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE api_grants RENAME COLUMN api_grant TO access_token"
  end

  def down do
    execute "ALTER TABLE api_grants RENAME COLUMN access_token TO api_grant"
  end
end
