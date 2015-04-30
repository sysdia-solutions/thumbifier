defmodule UserTest do
  use ExUnit.Case
  alias Ecto.Adapters.SQL

  setup do
    SQL.begin_test_transaction(Thumbifier.Repo)

    on_exit fn ->
      SQL.rollback_test_transaction(Thumbifier.Repo)
    end

    user =
      %Thumbifier.User{
        email: "Luke@Skywalker.com",
        api_token: "rebel",
        api_grant: "jedi",
        usage_limit: 0,
        usage_counter: 0,
        usage_reset_at: nil,
        total_usage: 0
      }
      |> Thumbifier.Repo.insert

    {:ok, user: user}
  end

  test "find", %{user: user} do
    assert user == Thumbifier.User.find(%{email: user.email})
    assert nil == Thumbifier.User.find(%{email: "Darth@Vadar.com"})
  end
end
