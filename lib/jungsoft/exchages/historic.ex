defmodule Jungsoft.Exchages.Historic do
  @moduledoc """
  Historic of token movimentation

  To sum users profits
  """
  use Ecto.Schema
  import Ecto.Changeset

  @required ~w[value token_id]a
  @optional ~w[from_user_id to_user_id]a

  schema "historics" do
    field :value, :decimal

    belongs_to :token, Jungsoft.Exchages.Token
    belongs_to :from_user, Jungsoft.Exchages.User, type: :binary_id
    belongs_to :to_user, Jungsoft.Exchages.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(fund, attrs) do
    fund
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
