defmodule Jungsoft.Exchages.Fund do
  @moduledoc """
  Fund where the tokens are exchanged

  The value is set with the admin evaluation
  """
  use Ecto.Schema
  import Ecto.Changeset

  @required ~w[name value]a
  @optional ~w[description]a

  schema "funds" do
    field :name, :string
    field :description, :string, default: ""
    field :value, :decimal

    has_many :tokens, Jungsoft.Exchages.Token

    timestamps()
  end

  @doc false
  def changeset(fund, attrs) do
    fund
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:name)
  end
end
