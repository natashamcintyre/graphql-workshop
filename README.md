# ExAmple

Could you get the smoke tests to work? If not, try pasting the query or mutation below into the left hand panel on the interface, and press the play button :)

```graphql
query test {
  isThisThingOn
}
```

```graphql
mutation echo {
  echoText(input: "Hello FAC")
}
```

## My first query

Now that we have successfully wired up our new app, we need to be able to query for some data.

Our next challenge will be to implement a new query which will get some data from our database, and expose it in our API. Along the way we will learn how Absinthe looks at things, and what we can do about it.

We have mocked a database (yeah, that's as crazy as it sounds) that contains address data and land registry housing data.

Your task is to implement a query for all of the addresses we have in our 'Database', and you'll know you have successfully implemented the feature when all the (delightfully-already-written-for-you) tests are green.

To get started head to the tests in `apps/graphql/test/integration/my_first_query_test.exs` run them with `mix test` to see them fail. Then head to `apps/graphql/lib/graphql_web/schema.ex` for hints on how to get going.

When it passes try booting the server with `mix phx.server` then head to `localhost:4000/graphiql` and try running the query using graphiql.

When you're done, checkout `my-second-query` for more querying fun!
