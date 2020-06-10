defmodule Jungsoft.Exchages.Token do
  @moduledoc """
  Token of a fund

  Make it easy to find the owner without lookup on the historic
  """
  use Ecto.Schema
  import Ecto.Changeset

  @required ~w[fund_id]a
  @optional ~w[current_owner_id]a

  schema "tokens" do
    belongs_to :current_owner, Jungsoft.Exchages.User, type: :binary_id
    belongs_to :fund, Jungsoft.Exchages.Fund

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
