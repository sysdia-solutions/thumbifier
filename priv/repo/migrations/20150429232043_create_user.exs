defmodule Thumbifier.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :api_token, :string
      add :api_grant, :string
      add :usage_limit, :integer, default: 1
      add :usage_counter, :integer, default: 0
      add :usage_reset_at, :datetime
      add :total_usage, :integer, default: 0

      timestamps
    end
  end
end
