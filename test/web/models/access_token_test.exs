defmodule AccessTokenTest do
  use Thumbifier.ConnCase

  setup do
    {:ok, access_token} =
      %Thumbifier.AccessToken{
        user_email: "luke@skywalker.com",
        access_token: "rebels"
      }
      |> Thumbifier.Repo.insert

    create_access_token("yoda@jedi.com", "yoda1", mins: 10)
    create_access_token("yoda@jedi.com", "yoda2", mins: 1)
    create_access_token("yoda@jedi.com", "yoda3", mins: 0)
    create_access_token("yoda@jedi.com", "yoda4", mins: -5)

    {:ok, access_token: access_token}
  end

  defp create_access_token(user_email, access_token, expire_shift) do
    %Thumbifier.AccessToken{
      user_email: user_email,
      access_token: access_token,
      expires_at: Thumbifier.Util.Time.ecto_now |> Thumbifier.Util.Time.ecto_shift(expire_shift)
    }
    |> Thumbifier.Repo.insert
  end

  test "generate" do
    assert Thumbifier.AccessToken.generate |> String.length == 36
  end

  test "new" do
    assert Thumbifier.AccessToken.new("imperials", "dartg@vader.com") == %{access_token: "imperials"}
  end

  test "find - nil on failure" do
    assert Thumbifier.AccessToken.find(%{access_token: "droids"}) == nil
  end

  test "find - AccessToken on success", %{access_token: access_token} do
    new_access_token = Thumbifier.AccessToken.find(%{access_token: access_token.access_token})
    assert new_access_token == access_token
  end

  test "delete - false on failure" do
    assert Thumbifier.AccessToken.delete(%{access_token: "droids"}) == false
  end

  test "delete - true on success", %{access_token: access_token} do
    assert Thumbifier.AccessToken.delete(%{access_token: access_token.access_token}) == true
  end

  test "purge() - deletes all expired access_tokens" do
    Thumbifier.AccessToken.purge()

    assert Thumbifier.AccessToken.find(%{access_token: "yoda1"}) != nil
    assert Thumbifier.AccessToken.find(%{access_token: "yoda2"}) != nil
    assert Thumbifier.AccessToken.find(%{access_token: "yoda3"}) == nil
    assert Thumbifier.AccessToken.find(%{access_token: "yoda4"}) == nil
  end

  test "purge(%{user_email: user_email}) - deletes all access_tokens for given email" do
    Thumbifier.AccessToken.purge(%{user_email: "yoda@jedi.com"})

    assert Thumbifier.AccessToken.find(%{access_token: "yoda1"}) == nil
    assert Thumbifier.AccessToken.find(%{access_token: "yoda2"}) == nil
    assert Thumbifier.AccessToken.find(%{access_token: "yoda3"}) == nil
    assert Thumbifier.AccessToken.find(%{access_token: "yoda4"}) == nil

    assert Thumbifier.AccessToken.find(%{access_token: "rebels"}) != nil
  end
end
