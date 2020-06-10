defmodule Jungsoft.Exchages do
  @moduledoc """
  The Exchages context.
  """

  import Ecto.Query, warn: false
  alias Jungsoft.Repo

  alias Jungsoft.Exchages.{Historic, Token, Fund, User}

  ########
  # USER #
  ########

  @doc """
  ## Examples
      iex> create_user(%{name: "DIO", email: "jotaro@hotmail.com", password: "secret"}),
      {:ok, %User{}} 

      iex> create_user(%{field: "asdkj"}),
      {:error, %Ecto.Changeset{}}
  """
  @spec create_user(map()) :: {:ok, %User{}} | {:error, %Ecto.Changeset{}}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  ## Examples
      iex> list_users()
      [%User{}]
  """
  @spec list_users :: [%User{}]
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user with email info

  ## Examples
      iex> get_user_by_email("dio@hotmail.com")
      %User{}

      iex> get_user_by_email("haha")
      nil
  """
  @spec get_user_by_email(:string) :: %User{} | nil
  def get_user_by_email(email) do
    Repo.one(
      from u in User,
        where: u.email == ^email
    )
  end

  @doc """
  Verify the password using the Argon2

      iex> authenticate("jotaro@hotmail.com", "secret")
      {:ok, %User{}}

      iex> authenticate("dio@com", "no no no no")
      {:error, "not found"}

      iex> authenticate("dio@hotmail.com", "no no no no")
      {:error, "invalid password"}
  """
  @spec authenticate(:string, :string) :: {:ok, %User{}} | {:error, bitstring()}
  def authenticate(email, password) do
    case get_user_by_email(email) do
      nil ->
        # Run a dummy check, which always returns false, to make user enumeration more difficult
        Argon2.no_user_verify()
        {:error, "not found"}

      user ->
        Argon2.check_pass(user, password)
    end
  end

  #########
  # TOKEN #
  #########

  @doc """
  Create a new token with current_owner_id as nil (corresponding as the exchanger owner)

  ## Examples
      iex> create_token(fund)
      {:ok, %Fund{}}

      iex> create_token(fund_error)
      {:error, %Ecto.Changeset{}}
  """
  @spec create_token(%Fund{}) :: {:ok, %Fund{}} | {:error, %Ecto.Changeset{}}
  def create_token(fund = %Fund{}) do
    %Token{}
    |> Token.changeset(%{current_owner_id: nil, fund_id: fund.id})
    |> Repo.insert()
  end

  @doc """
  Update the owner of the topic, if the owner is null, then it is the exchange

  ## Examples
      iex> update_token_owner(token, owner)
      {:ok, %Token{}}

      iex> update_token_owner(token, owner)
      {:error, %Ecto.Changeset{}}
  """
  @spec update_token_owner(%Token{}, %User{} | nil) :: {:ok, %Token{}} | {:error, %Ecto.Changeset{}}
  def update_token_owner(%Token{} = token, owner_id) do
    token
    |> Token.changeset(%{current_owner_id: owner_id})
    |> Repo.update()
  end

  ########
  # FUND #
  ########

  @doc """
  Create a new fund with limited tokens

  ## Examples

      iex> create_fund(%{name: "dio", value: 10, token_amount: 100})
      {:ok, %Fund{}}

      iex> create_fund(%{})
      {:error, reason}
  """
  @spec create_fund(map()) ::
          {:ok, %Fund{}} | {:error, %Ecto.Changeset{}} | {:error, :token_amount_missed}
  def create_fund(attrs \\ %{})

  def create_fund(attrs = %{token_amount: token_amount}) when is_integer(token_amount) do
    with {:ok, fund} <-
           %Fund{}
           |> Fund.changeset(attrs)
           |> Repo.insert() do
      Enum.each(1..token_amount, fn _ -> create_token(fund) end)
      {:ok, fund}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def create_fund(_attrs) do
    {:error, :token_amount_missed}
  end

  @doc """
  Update a fund, main use to update the value of the fund

  ## Examples
      iex> update_fund(fund, %{value: 12})
      {:ok, %Fund{}}

      iex> update_fund(fund, %{})
      {:error, reason}
  """
  @spec update_fund(%Fund{}, map()) :: {:ok, %Fund{}} | {:error, %Ecto.Changeset{}}
  def update_fund(%Fund{} = fund, attrs \\ %{}) do
    fund
    |> Fund.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  ## Examples
      iex> get_fund_by_name("dio")
      %Fund{}

      iex> get_fund_by_name("JOJO")
      nil
  """
  @spec get_fund_by_name(:string) :: %Fund{} | nil
  def get_fund_by_name(name) do
    Repo.one(
      from f in Fund,
        where: f.name == ^name
    )
  end

  @doc """
  ## Examples
      iex> list_funds()
      [%Fund{}]
  """
  @spec list_funds :: [%Fund{}]
  def list_funds do
    Repo.all(Fund)
  end

  @doc """
  Invest x amount of tokens in a fund from the current user

  Notes:
  - If the amount is more than the user have, then all tokens will be acounted!
  - The default `token_amount` is 1
  """
  @spec invest(%User{}, %Fund{}, integer()) ::
          [{:ok, %Historic{}} | {:error, %Ecto.Changeset{}}]
  def invest(current_user = %User{}, fund = %Fund{}, token_amount \\ 1) do
    disponible_tokens =
      Repo.all(
        from t in Token, where: t.fund_id == ^fund.id and is_nil(t.current_owner_id) == true
      )

    tokens = Enum.slice(disponible_tokens, 0, token_amount)

    Enum.map(tokens, fn token -> create_historic(nil, current_user.id, token, fund.value) end)

    # get the token from the exchange
    Enum.map(tokens, fn token -> update_token_owner(token, current_user.id) end)
  end

  @doc """
  Refunds x amount of tokens in a fund from the current user

  Notes: 
  - If the amount is more than the user have, then all tokens will be acounted!
  - The default `token_amount` is 1
  """
  @spec refund(%User{}, %Fund{}, integer()) ::
          [{:ok, %Historic{}} | {:error, %Ecto.Changeset{}}]
  def refund(current_user = %User{}, fund = %Fund{}, token_amount \\ 1) do
    disponible_tokens =
      Repo.all(
        from t in Token, where: t.fund_id == ^fund.id and t.current_owner_id == ^current_user.id)

    tokens = Enum.slice(disponible_tokens, 0, token_amount)

    Enum.map(tokens, fn token -> create_historic(current_user.id, nil, token, fund.value) end)

    # send the token back to the exchange
    Enum.map(tokens, fn token -> update_token_owner(token, nil) end)
  end

  ############
  # HISTORIC #
  ############

  @doc """
  Get the user profit of ALL historics!

  ## Examples
      iex> get_user_profit(current_user)
      Decimal<100000>

      iex> get_user_profit(current_user)
      Decimal<-100>
  """
  @spec get_user_profit(%User{}) :: Decimal.t()
  def get_user_profit(user = %User{}) do
    user =
      user
      |> Repo.preload(:sell_historics)
      |> Repo.preload(:buy_historics)

    gain = Enum.reduce(user.sell_historics, Decimal.new(0), &(Decimal.add(&1.value, &2)))
    loss = Enum.reduce(user.buy_historics, Decimal.new(0), &(Decimal.add(&1.value, &2)))

    Decimal.sub(gain, loss)
  end

  @doc """
  Create a new entry on the historic

  WARNING: Do not use this function as a public API

  ## Examples
      iex> create_historic(from_user, to_user, token, 10)
      {:ok, %Historic{}}

      iex> create_historic(from_user, to_user, token, 10)
      {:error, %Ecto.Changeset{}}
  """
  @spec create_historic(Ecto.UUID.t() | nil, Ecto.UUID.t() | nil, %Token{}, Decimal.t()) ::
          {:ok, %Historic{}} | {:error, %Ecto.Changeset{}}
  def create_historic(from_user_id, to_user_id, token = %Token{}, value) do
    %Historic{}
    |> Historic.changeset(%{
      value: value,
      token_id: token.id,
      from_user_id: from_user_id,
      to_user_id: to_user_id
    })
    |> Repo.insert()
  end
end
