defmodule JungsoftWeb.Schema.Fund do
  @moduledoc false

  use Absinthe.Schema.Notation

  object :fund do
    field :name, :string
    field :description, :string
    field :value, :decimal
  end

  #########
  # QUERY #
  #########
  @desc "Fund get and list"
  object :fund_queries do
    @desc """
    PUBLIC

    get a specific fund
    """
    field :get_fund, :fund do
      arg(:name, non_null(:string))
      resolve(&Jungsoft.Resolver.get_fund/3)
    end

    @desc """
    PUBLIC

    list all funds
    """
    field :list_funds, list_of(:fund) do
      resolve(&Jungsoft.Resolver.list_funds/3)
    end
  end

  ############
  # MUTATION #
  ############
  @desc "Fund mannagement"
  object :fund_mutations do
    @desc """
    ADMIN ONLY

    Create a new Fund with the amount of tokens
    """
    field :create_fund, :fund do
      arg(:name, non_null(:string))
      arg(:description, :string)
      arg(:value, non_null(:decimal))
      arg(:token_amount, non_null(:integer))
      resolve(&Jungsoft.Resolver.create_fund/3)
    end

    @desc """
    ADMIN ONLY

    Update the fund valuetion
    """
    field :update_fund, :fund do
      arg(:value, non_null(:decimal))
      arg(:fund_name, non_null(:string))
      resolve(&Jungsoft.Resolver.update_fund/3)
    end

    @desc """
    CURRENT USER

    Make a invest, returns the current user profit
    """
    field :invest, :decimal do
      arg(:fund_name, non_null(:string))
      arg(:token_amount, non_null(:integer))
      resolve(&Jungsoft.Resolver.invest/3)
    end

    @desc """
    CURRENT USER

    Make a refund, returns the current user profit
    """
    field :refund, :decimal do
      arg(:fund_name, non_null(:string))
      arg(:token_amount, non_null(:integer))
      resolve(&Jungsoft.Resolver.refund/3)
    end
  end
end
