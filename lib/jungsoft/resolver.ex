defmodule Jungsoft.Resolver do
  @moduledoc """
  Handle all information on the absinthe schemas, geting results, inserting from/to DB
  """

  alias Jungsoft.Exchages
  alias Jungsoft.Exchages.{Fund, User}

  ########
  # UTIL #
  ########

  @typedoc """
  The type of the %Ecto.Changeset{} when parsed by `transform_errors/1`
  """
  @type changeset_error :: [%{key: :string, message: any}]

  @doc """
  Transform a error changeset to a error in Absinthe
  """
  @spec transform_errors(%Ecto.Changeset{}) :: changeset_error()
  def transform_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_error/1)
    |> Enum.map(fn {key, value} ->
      %{key: key, message: value}
    end)
  end

  defp format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  ###########
  # SESSION #
  ###########

  @doc """
  Verify the email and password, gen a token with `Jungsoft.Authentication.sign/1` and send in the API

  With the token, the client can pass a HTTP Header "Authorization" with "Bearer {token}", that will be used by the `Jungsoft.Context` plug in the endpoint to fill the context for others mutations (the plug need the user ID of the token)
  """
  @spec login(any, %{email: :string, password: :string}, any) ::
          {:error, bitstring()} | {:ok, %{token: :string}, user: %User{}}
  def login(_root, %{email: email, password: password}, _info) do
    case Exchages.authenticate(email, password) do
      {:ok, user} ->
        token =
          JungsoftWeb.Authentication.sign(%{
            id: user.id
          })

        {:ok, %{token: token, user: user}}

      {:error, error_str} ->
        # will be "not found" or "invalid password"
        {:error, error_str}
    end
  end

  @doc """
  Verify if the context have %{current_user: %User{}}
  """
  @spec me(any, any, any) :: {:ok, %User{}} | {:error, nil}
  def me(_root, _attrs, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def me(_root, _attrs, _info) do
    {:error, "invalid token"}
  end

  ########
  # FUND #
  ########

  @doc """
  [ADMIN ONLY] Create a new fund with the amount of tokens
  """
  @spec create_fund(any, map(), %{context: %{current_user: %{role: bitstring()}}}) ::
          {:ok, %Fund{}}
          | {:error,
             :token_amount_missed
             | :invalid_or_unauthorized
             | changeset_error()}
  def create_fund(_root, attrs, %{context: %{current_user: %{role: "admin"}}}) do
    case Exchages.create_fund(attrs) do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, transform_errors(changeset)}

      any ->
        any
    end
  end

  def create_fund(_root, _attrs, _info), do: {:error, :invalid_or_unauthorized}

  @doc """
  [ADMIN ONLY] Update the fund
  """
  @spec update_fund(any, %{fund_name: :string}, %{
          context: %{current_user: %{role: bitstring()}}
        }) ::
          {:ok, %Fund{}}
          | {:error, changeset_error() | :invalid_or_unauthorized}
  def update_fund(_root, attrs = %{fund_name: fund_name}, %{
        context: %{current_user: %{role: "admin"}}
      }) do
    fund = Exchages.get_fund_by_name(fund_name)

    case Exchages.update_fund(fund, attrs) do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, transform_errors(changeset)}

      any ->
        any
    end
  end

  def update_fund(_root, _attrs, _info), do: {:error, :invalid_or_unauthorized}

  @doc """
  get one fund by name
  """
  @spec get_fund(any, %{name: :string}, any) :: {:ok, %Fund{} | nil}
  def get_fund(_root, %{name: name}, _info) do
    {:ok, Exchages.get_fund_by_name(name)}
  end

  @doc """
  list all funds
  """
  @spec list_funds(any, any, any) :: {:ok, [%Fund{}]}
  def list_funds(_root, _attrs, _info) do
    {:ok, Exchages.list_funds()}
  end

  @doc """
  [CURRENT USER] Make a invest in a fund
  """
  @spec invest(any, %{fund_name: :string, token_amount: non_neg_integer}, %{
          context: %{current_user: %User{}}
        }) :: {:ok, Decimal.t()}
  def invest(_root, %{fund_name: fund_name, token_amount: token_amount}, %{
        context: %{current_user: current_user}
      }) do
    fund = Exchages.get_fund_by_name(fund_name)
    {:ok, Exchages.invest(current_user, fund, token_amount)}
  end

  @doc """
  [CURRENT USER] Make a refund in a fund
  """
  @spec refund(any, %{fund_name: :string, token_amount: non_neg_integer}, %{
          context: %{current_user: %User{}}
        }) :: {:ok, Decimal.t()}
  def refund(_root, %{fund_name: fund_name, token_amount: token_amount}, %{
        context: %{current_user: current_user}
      }) do
    fund = Exchages.get_fund_by_name(fund_name)
    {:ok, Exchages.refund(current_user, fund, token_amount)}
  end

  ############
  # HISTORIC #
  ############

  @doc """
  [CURRENT USER] Get the profit
  """
  @spec get_user_profit(any, any, %{context: %{current_user: %User{}}}) :: {:ok, Decimal.t()}
  def get_user_profit(_root, _attrs, %{context: %{current_user: current_user}}) do
    {:ok, Exchages.get_user_profit(current_user)}
  end
end
