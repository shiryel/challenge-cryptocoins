defmodule JungsoftWeb.Schema.Session do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc "Info returned in the authentication phase"
  object :session do
    field :token, :string
    field :user, :user
  end

  # MUTATION
  @desc "Exec a session authentication"
  object :session_mutations do
    @desc "User credentials"
    field :login, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &Jungsoft.Resolver.login/3
    end
  end
end
