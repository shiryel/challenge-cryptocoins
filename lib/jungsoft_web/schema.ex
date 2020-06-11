defmodule JungsoftWeb.Schema do
  @moduledoc """
  Absinthe GraphQL Schema
  """

  use Absinthe.Schema
  import_types(Absinthe.Type.Custom)
  import_types(__MODULE__.Session)
  import_types(__MODULE__.Fund)
  import_types(__MODULE__.Historic)

  ##############
  # ROOT TYPES #
  ##############

  @desc "User info, get from the authentication"
  object :user do
    @desc "User name"
    field :name, :string
    @desc "User email, used on login"
    field :email, :string
  end

  object :me_queries do
    import_fields(:user)
    import_fields(:fund_queries)
    import_fields(:historic_queries)
  end

  object :me_mutations do
    import_fields(:fund_mutations)
  end

  ##############

  query do
    @desc """
    Generate a context based on the token from the login

    NOTE: You need to use the HTTP Header "Authorization" with "Bearer {token}" from the mutation login(email, password) !!!
    """
    field :me, :me_queries do
      resolve(&Jungsoft.Resolver.me/3)
    end
  end

  mutation do
    field :me, :me_mutations do
      resolve(&Jungsoft.Resolver.me/3)
    end
    import_fields(:session_mutations)
  end
end
