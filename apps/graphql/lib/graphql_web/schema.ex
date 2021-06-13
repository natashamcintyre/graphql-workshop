defmodule Graphql.Schema do
  use Absinthe.Schema

  object :address do
    field :id, :id
    field :house_number, :integer
    field :postcode, :string
  end

  query do
    field :is_this_thing_on, type: :string do
      resolve(&Graphql.Resolver.smoke_test/2)
    end

    field :get_addresses, type: list_of(:address) do
      # We need to add a resolving function here!
      resolve(&Graphql.Resolver.addresses/2)
    end
  end

  mutation do
    field :echo_text, type: :string do
      arg(:input, :string)
      resolve(&Graphql.Resolver.test_update/2)
    end
  end
end
