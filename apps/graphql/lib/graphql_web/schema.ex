defmodule Graphql.Schema do
  use Absinthe.Schema

  object :address do
    field(:id, non_null(:id))
    field(:postcode, :string)
    field(:house_number, :integer)
  end

  object :land_reg_data do
    field(:id, non_null(:id))
    field(:address_id, non_null(:id))
    field(:average_time_to_sold, :integer)
  end

  query do
    field :is_this_thing_on, type: :string do
      resolve(&Graphql.Resolver.smoke_test/2)
    end

    field :get_addresses, type: list_of(:address) do
      resolve(&Graphql.Resolver.addresses/2)
    end

    field :land_reg_data, type: list_of(:land_reg_data) do
      arg(:address_id, :id)
      resolve(&Graphql.Resolver.average_time_to_sold/2)
    end
    # implement your new query here, this time our field will need an arg... check out the
    # mutation for a clue
  end

  mutation do
    field :echo_text, type: :string do
      arg(:input, :string)
      resolve(&Graphql.Resolver.test_update/2)
    end
  end
end
