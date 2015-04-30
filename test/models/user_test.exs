defmodule UserTest do
  use ExUnit.Case
  alias Ecto.Adapters.SQL

  setup do
    SQL.begin_test_transaction(Thumbifier.Repo)

    on_exit fn ->
      SQL.rollback_test_transaction(Thumbifier.Repo)
    end

    token = "rebel"
    user =
      %Thumbifier.User{
        email: "Luke@Skywalker.com",
        api_token: token |> Thumbifier.User.hash,
        api_grant: "jedi",
        usage_limit: 0,
        usage_counter: 0,
        usage_reset_at: Ecto.DateTime.local(),
        total_usage: 0
      }
      |> Thumbifier.Repo.insert

    {:ok, user: user, token: token}
  end

  test "find", %{user: user, token: token} do
    assert user == Thumbifier.User.find(%{email: user.email})
    assert nil == Thumbifier.User.find(%{email: "Darth@Vadar.com"})
    assert user == Thumbifier.User.find(%{email: user.email, api_token: token})
    assert nil == Thumbifier.User.find(%{email: "darth@vadar.com", api_token: "sith"})
    assert nil == Thumbifier.User.find(%{email: user.email, api_token: "sith"})
  end

  test "generate_grant", %{user: user} do
    check_user = Thumbifier.User.find(%{email: user.email})
    assert check_user.api_grant == user.api_grant

    Thumbifier.User.generate_grant(user)

    check_user = Thumbifier.User.find(%{email: user.email})
    assert check_user.api_grant != user.api_grant
    assert check_user.api_grant |> String.length() == 36
  end
end
