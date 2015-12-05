defmodule UserTest do
  use Thumbifier.ConnCase

  setup do
    key_luke_skywalker = "rebel"
    {:ok, user_luke_skywalker} =
      %Thumbifier.User{
        email: "Luke@Skywalker.com",
        api_key: key_luke_skywalker |> Thumbifier.User.hash,
        usage_limit: 10,
        usage_counter: 0,
        usage_reset_at: Thumbifier.Util.Time.ecto_now,
        total_usage: 0
      }
      |> Thumbifier.Repo.insert

    {:ok, user_darth_vader} =
      %Thumbifier.User{
        email: "Darth@Vader.com",
        api_key: "sith" |> Thumbifier.User.hash,
        usage_limit: 10,
        usage_counter: 10,
        usage_reset_at: Thumbifier.Util.Time.ecto_now,
        total_usage: 0
      }
      |> Thumbifier.Repo.insert

    {:ok, user_darth_maul} =
      %Thumbifier.User{
        email: "Darth@Maul.com",
        api_key: "republican" |> Thumbifier.User.hash,
        usage_limit: 10,
        usage_counter: 10,
        usage_reset_at: Thumbifier.Util.Time.ecto_now |> Thumbifier.Util.Time.ecto_shift(mins: -15),
        total_usage: 0
      }
      |> Thumbifier.Repo.insert

    {:ok, user_luke_skywalker: user_luke_skywalker, user_darth_vader: user_darth_vader, user_darth_maul: user_darth_maul, key_luke_skywalker: key_luke_skywalker}
  end

  test "find", %{user_luke_skywalker: user_luke_skywalker, key_luke_skywalker: key_luke_skywalker} do
    assert user_luke_skywalker == Thumbifier.User.find(%{email: user_luke_skywalker.email})
    assert nil == Thumbifier.User.find(%{email: "Darth@Vadar.com"})
    assert user_luke_skywalker == Thumbifier.User.find(%{email: user_luke_skywalker.email, api_key: key_luke_skywalker})
    assert nil == Thumbifier.User.find(%{email: "darth@vadar.com", api_key: "sith"})
    assert nil == Thumbifier.User.find(%{email: user_luke_skywalker.email, api_key: "sith"})
  end

  test "new - success" do
    email = "yoda@theforce.com"
    new_user = Thumbifier.User.new(%{email: email})

    assert new_user.email == email
    assert new_user.api_key |> String.length == 36

    found_user = Thumbifier.User.find(%{email: email})

    assert found_user.email == email
    assert found_user.api_key |> String.length == 128
    assert found_user.usage_limit == 10
    assert found_user.usage_counter == 0
    assert found_user.total_usage == 0
  end

  test "new - failure due to invalid email" do
    assert Thumbifier.User.new(%{email: "jajabink"}) == %{error: [email: "has invalid format"]}
  end

  test "new - failure due to duplicate email", %{user_luke_skywalker: user_luke_skywalker} do
    assert Thumbifier.User.new(%{email: user_luke_skywalker.email}) == %{error: [email: "has already been taken"]}
  end

  test "delete - success", %{user_luke_skywalker: user_luke_skywalker} do
    assert Thumbifier.User.delete(%{email: user_luke_skywalker.email}) == true
    assert Thumbifier.User.find(%{email: user_luke_skywalker.email}) == nil
  end

  test "delete - failure due to email not found" do
    assert Thumbifier.User.delete(%{email: "yoda@theforce.com"}) == false
  end

  test "update_email - success", %{user_luke_skywalker: user_luke_skywalker}  do
    update_user = %{ user_luke_skywalker | email: "han@solo.com" }
    assert Thumbifier.User.update_email(user_luke_skywalker, %{new_email: update_user.email}) == update_user
  end

  test "update_email - failure due to email not valid", %{user_luke_skywalker: user_luke_skywalker} do
    invalid_email = "jajabinks"
    assert Thumbifier.User.update_email(user_luke_skywalker, %{new_email: invalid_email}) == %{error: [email: "has invalid format"]}
  end

  test "update_email - failure due to email is duplicate", %{user_luke_skywalker: user_luke_skywalker} do
    duplicate_user = Thumbifier.User.new(%{email: "han@solo.com"})
    assert Thumbifier.User.update_email(user_luke_skywalker, %{new_email: duplicate_user.email}) == %{error: [email: "has already been taken"]}
  end

  test "under_usage_limit? - is true if user has not exceeded limit", %{user_luke_skywalker: user_luke_skywalker} do
    check_user = Thumbifier.User.find(%{email: user_luke_skywalker.email})
    assert Thumbifier.User.under_usage_limit?(check_user) == true
  end

  test "under_usage_limit? - is false if user has exceeded limit", %{user_darth_vader: user_darth_vader} do
    check_user = Thumbifier.User.find(%{email: user_darth_vader.email})
    assert Thumbifier.User.under_usage_limit?(check_user) == false
  end

  test "under_usage_limit? - is true as usage counter resets if reset time exceeded", %{user_darth_maul: user_darth_maul} do
    check_user = Thumbifier.User.find(%{email: user_darth_maul.email})
    assert Thumbifier.User.under_usage_limit?(check_user) == true
  end

  test "update_usage_counter", %{user_luke_skywalker: user_luke_skywalker} do
    check_user = Thumbifier.User.find(%{email: user_luke_skywalker.email})
    assert check_user.usage_counter == user_luke_skywalker.usage_counter
    assert check_user.total_usage == user_luke_skywalker.total_usage

    updated_user = Thumbifier.User.update_usage_counter(check_user)

    assert updated_user.usage_counter == user_luke_skywalker.usage_counter + 1
    assert updated_user.total_usage == user_luke_skywalker.total_usage + 1
  end
end
