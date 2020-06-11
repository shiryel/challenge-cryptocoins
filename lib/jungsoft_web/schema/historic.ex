defmodule JungsoftWeb.Schema.Historic do
  @moduledoc false

  use Absinthe.Schema.Notation

  #########
  # QUERY #
  #########
  @desc "Historic relative queries"
  object :historic_queries do
    @desc """
    CURRENT USER

    Get the current user profit
    """
    field :get_user_profit, :decimal do
      resolve(&Jungsoft.Resolver.get_user_profit/3)
    end
  end
end
