defmodule Graphql.Resolver do
  # https://hexdocs.pm/absinthe/query-arguments.html
  # These have 2 args, whereas docs have 3. Is it because they are namespaced Resolvers.Accounts... etc?
  def smoke_test(_args, _info) do
    {:ok, "Yes!"}
  end

  def test_update(%{input: input}, _info) do
    {:ok, input}
  end
end
