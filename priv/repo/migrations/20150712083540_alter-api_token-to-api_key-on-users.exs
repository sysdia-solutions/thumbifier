defmodule :"Elixir.Thumbifier.Repo.Migrations.Alter-apiToken-to-apiKey-on-users" do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE users RENAME COLUMN api_token TO api_key"
  end

  def down do
    execute "ALTER TABLE users RENAME COLUMN api_key TO api_token"
  end
end
