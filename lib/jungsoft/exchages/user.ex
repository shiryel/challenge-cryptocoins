defmodule Jungsoft.Exchages.User do
  @moduledoc """
  The user of the system
  Can have the roles: "client" "admin"
  Stores the password as a hash
  The ID is UUID to prevent user count
  """
  use Ecto.Schema
  import Ecto.Changeset

  # For security, maybe is better to create a changeset unic to make admin users
  @required ~w[name email password role]a

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :email, :string
    field :role, :string, default: "client"
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :tokens, Jungsoft.Exchages.Token, foreign_key: :current_owner_id
    has_many :sell_historics, Jungsoft.Exchages.Historic, foreign_key: :from_user_id
    has_many :buy_historics, Jungsoft.Exchages.Historic, foreign_key: :to_user_id

    timestamps()
  end

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset = %Ecto.Changeset{valid?: true, changes: %{password: pass}}) do
    put_change(changeset, :password_hash, Argon2.add_hash(pass)[:password_hash])
  end

  defp put_pass_hash(changeset), do: changeset
end
