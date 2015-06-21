defmodule ApiGrantTest do
  use Thumbifier.ConnCase

  setup do
    api_grant =
      %Thumbifier.ApiGrant{
        user_email: "luke@skywalker.com",
        api_grant: "rebels"
      }
      |> Thumbifier.Repo.insert

    create_api_grant("yoda@jedi.com", "yoda1", mins: 10)
    create_api_grant("yoda@jedi.com", "yoda2", mins: 1)
    create_api_grant("yoda@jedi.com", "yoda3", mins: 0)
    create_api_grant("yoda@jedi.com", "yoda4", mins: -5)

    {:ok, api_grant: api_grant}
  end

  defp create_api_grant(user_email, api_grant, expire_shift) do
    %Thumbifier.ApiGrant{
      user_email: user_email,
      api_grant: api_grant,
      expires_at: Thumbifier.Util.Time.ecto_now |> Thumbifier.Util.Time.ecto_shift(expire_shift)
    }
    |> Thumbifier.Repo.insert
  end

  test "generate" do
    assert Thumbifier.ApiGrant.generate |> String.length == 36
  end

  test "new" do
    assert Thumbifier.ApiGrant.new("imperials", "dartg@vader.com") == %{api_grant: "imperials"}
  end

  test "find - nil on failure" do
    assert Thumbifier.ApiGrant.find(%{api_grant: "droids"}) == nil
  end

  test "find - ApiGrant on success", %{api_grant: api_grant} do
    new_api_grant = Thumbifier.ApiGrant.find(%{api_grant: api_grant.api_grant})
    assert new_api_grant == api_grant
  end

  test "delete - false on failure" do
    assert Thumbifier.ApiGrant.delete(%{api_grant: "droids"}) == false
  end

  test "delete - true on success", %{api_grant: api_grant} do
    assert Thumbifier.ApiGrant.delete(%{api_grant: api_grant.api_grant}) == true
  end

  test "purge() - deletes all expired api_grants" do
    Thumbifier.ApiGrant.purge()

    assert Thumbifier.ApiGrant.find(%{api_grant: "yoda1"}) != nil
    assert Thumbifier.ApiGrant.find(%{api_grant: "yoda2"}) != nil
    assert Thumbifier.ApiGrant.find(%{api_grant: "yoda3"}) == nil
    assert Thumbifier.ApiGrant.find(%{api_grant: "yoda4"}) == nil
  end

  test "purge(%{user_email: user_email}) - deletes all api_grants for given email" do
    Thumbifier.ApiGrant.purge(%{user_email: "yoda@jedi.com"})

    assert Thumbifier.ApiGrant.find(%{api_grant: "yoda1"}) == nil
    assert Thumbifier.ApiGrant.find(%{api_grant: "yoda2"}) == nil
    assert Thumbifier.ApiGrant.find(%{api_grant: "yoda3"}) == nil
    assert Thumbifier.ApiGrant.find(%{api_grant: "yoda4"}) == nil

    assert Thumbifier.ApiGrant.find(%{api_grant: "rebels"}) != nil
  end
end
