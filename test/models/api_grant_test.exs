defmodule ApiGrantTest do
  use Thumbifier.ConnCase

  setup do
    api_grant =
      %Thumbifier.ApiGrant{
        user_email: "luke@skywalker.com",
        api_grant: "rebels"
      }
      |> Thumbifier.Repo.insert

    {:ok, api_grant: api_grant}
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
end
