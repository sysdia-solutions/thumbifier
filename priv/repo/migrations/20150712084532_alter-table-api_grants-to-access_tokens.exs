defmodule :"Elixir.Thumbifier.Repo.Migrations.Alter-table-apiGrants-to-accessTokens" do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE api_grants RENAME TO access_tokens"
  end

  def down do
    execute "ALTER TABLE access_tokens RENAME TO api_grants"
  end
end
