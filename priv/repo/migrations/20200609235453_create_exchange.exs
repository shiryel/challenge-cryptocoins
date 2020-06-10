defmodule Jungsoft.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    # The user of the system
    # Can have the roles: :client, :admin
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string, null: false
      add :email, :string, null: false
      add :role, :string, default: "client", null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    # A fund where the tokens are exchanged
    # The value is set with the admin evaluation
    create table(:funds) do
      add :name, :string, null: false
      add :description, :string
      add :value, :decimal, null: false

      timestamps()
    end

    create unique_index(:funds, [:name])

    # The token of a fund
    # Make it easy to find the owner without lookup on the historic
    # If current_owner is null, then the owner is the exchange!
    create table(:tokens) do
      add :current_owner_id, references(:users, type: :uuid), null: true
      add :fund_id, references(:funds), null: false

      timestamps()
    end

    # The historic to sum the users profits
    # If user is null, then is the exchange!
    create table(:historics) do
      add :token_id, references(:tokens), null: false
      add :from_user_id, references(:users, type: :uuid), null: true
      add :to_user_id, references(:users, type: :uuid), null: true
      add :value, :decimal, null: false

      timestamps()
    end
  end
end
