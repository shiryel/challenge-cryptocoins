defmodule Jungsoft.ExchagesTest do
  use Jungsoft.DataCase

  alias Jungsoft.Exchages

  describe "users" do
    alias Jungsoft.Exchages.User

    @valid_user %{email: "dio@hotmail.com", password: "42", name: "jotaro"}
    @invalid_user %{email: nil, password: nil, name: nil}

    test "list_users/0 returns all users" do
      {:ok, user} = Exchages.create_user(@valid_user)
      user_1 = Map.delete(user, :password)

      [user] = Exchages.list_users()
      user_2 = Map.delete(user, :password)
      assert user_1 == user_2
    end

    test "create_user/1 with valid data creates a user and od not returns the password" do
      assert {:ok, %User{} = user} = Exchages.create_user(@valid_user)
      assert user.email == "dio@hotmail.com"
      assert user.password_hash != "42"
      assert user.name == "jotaro"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exchages.create_user(@invalid_user)
    end

    test "get_user_by_email/1 returns the user" do
      {:ok, user} = Exchages.create_user(@valid_user)
      user_1 = Map.delete(user, :password)

      user_2 =
        Exchages.get_user_by_email("dio@hotmail.com")
        |> Map.delete(:password)

      assert user_1 == user_2
    end

    test "authenticate/2 returns the user when accepted" do
      {:ok, user} = Exchages.create_user(@valid_user)
      user_1 = Map.delete(user, :password)

      {:ok, user} = Exchages.authenticate("dio@hotmail.com", "42")
      user_2 = Map.delete(user, :password)

      assert user_1 == user_2
    end

    test "authenticate/2 returns error when not accepted" do
      assert {:error, "not found"} = Exchages.authenticate("dio@hotmail.com", "42")

      {:ok, _user} = Exchages.create_user(@valid_user)

      assert {:error, "invalid password"} = Exchages.authenticate("dio@hotmail.com", "24")
    end
  end

  describe "funds and tokens" do
    @valid_user %{email: "dio@hotmail.com", password: "42", name: "jotaro"}
    @valid_fund %{name: "dio", value: 10, token_amount: 10}
    @invalid_fund %{name: nil, value: nil, token_amount: nil}

    test "create_fund/1 creates a new fund with the amount of tokens" do
      {:ok, fund} = Exchages.create_fund(@valid_fund)
      assert fund.description == ""
      assert fund.name == "dio"
      assert fund.value == Decimal.new(10)

      fund = Repo.preload(fund, :tokens)
      token_amount = length(fund.tokens)

      assert token_amount == 10
    end

    test "create_fund/1 returns error with invalid input" do
      assert {:error, :token_amount_missed} = Exchages.create_fund(@invalid_fund)
    end

    test "get_fund_by_name/1 returns the fund" do
      {:ok, fund} = Exchages.create_fund(@valid_fund)
      assert fund == Exchages.get_fund_by_name("dio")
      
      assert nil == Exchages.get_fund_by_name("dio dio")
    end

    test "create_fund/1 cannot create 2 funds with same name" do
      assert {:ok, _fund} = Exchages.create_fund(@valid_fund)
      assert {:error, _changeset} = Exchages.create_fund(@valid_fund)
    end

    test "list_funds/0 will list the funds" do
      {:ok, fund} = Exchages.create_fund(@valid_fund)
      assert Exchages.list_funds() == [fund]
    end

    test "invest/3 will invest in a fund" do
      {:ok, user} = Exchages.create_user(@valid_user)
      {:ok, fund} = Exchages.create_fund(@valid_fund)

      assert [{:ok, _historic}] = Exchages.invest(user, fund, 1)

      assert Exchages.get_user_profit(user) == Decimal.new(-10)
    end

    test "refund/3 will refund tokens in a fund" do
      {:ok, user} = Exchages.create_user(@valid_user)
      {:ok, fund} = Exchages.create_fund(@valid_fund)

      assert [{:ok, _historic}] = Exchages.invest(user, fund, 1)

      assert [{:ok, _historic}] = Exchages.refund(user, fund, 1)

      assert Exchages.get_user_profit(user) == Decimal.new(0)
    end

    test "update_fund/2 update the fund value" do
      {:ok, user} = Exchages.create_user(@valid_user)
      {:ok, fund} = Exchages.create_fund(@valid_fund)

      Exchages.invest(user, fund, 2)

      assert {:ok, fund} = Exchages.update_fund(fund, %{value: 12})

      Exchages.refund(user, fund, 100)

      assert Exchages.get_user_profit(user) == Decimal.new(4)
    end
  end

  describe "historic" do
    @valid_user_1 %{email: "dio1@hotmail.com", password: "42", name: "jotaro1"}
    @valid_user_2 %{email: "dio2@hotmail.com", password: "42", name: "jotaro2"}
    @valid_fund %{name: "dio", value: 10, token_amount: 10}

    test "get_user_profit/1 from a new user will be 0" do
      {:ok, user} = Exchages.create_user(@valid_user)

      assert Exchages.get_user_profit(user) == Decimal.new(0)
    end

    test "create_historic/4 create a new historic" do
      {:ok, user_1} = Exchages.create_user(@valid_user_1)
      {:ok, user_2} = Exchages.create_user(@valid_user_2)
      {:ok, fund} = Exchages.create_fund(@valid_fund)

      fund = Repo.preload(fund, :tokens)
      token = List.first(fund.tokens)

      assert {:ok, _} = Exchages.create_historic(user_1.id, user_2.id, token, 12)

      assert {:ok, _} = Exchages.create_historic(nil, user_2.id, token, 12)

      assert {:ok, _} = Exchages.create_historic(user_1.id, nil, token, 12)
    end
  end
end
