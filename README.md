# GraphQL Workshop

Disclaimer: this is an almost identical copy of Adzz's [ex_ample repo](https://github.com/Adzz/ex_ample), but has been specially adapted to be shorter and accessible to those new to elixir and GraphQL.

The idea is to step through the branches completing the exercises outlined in the readme as you go. Answers can be found at the top of each branch's README for the preceeding section.

```
master
my-first-query
my-second-query
my-first-mutation
my-first-resolving-function
```

## Background information

**Note, these are NOT instructions - you don't need to do anything outlined in this section, but please read to understand the structure of the repo**

### Umbrella projects

This repo is an 'umbrella' project. [Umbrella projects](https://8thlight.com/blog/georgina-mcfadyen/2017/05/01/elixir-umbrella-projects.html) are a great way to manage internal dependencies for your applications. Internal dependencies can be thought of as libraries that can sit on their own - but that you don't want to or cannot open source. They are things that you can configure their own releases for (so can be released independently from the rest of the application), but are conveniently grouped together into one git repo.

<details>
<summary>When is an umbrella project a good idea?</summary>
<br/>
If you have ever had one repo rely on another, you'll soon find umbrella projects to be lifesavers; no more using git tags and bumping versions in your mix files so you can get new features!

However, apps within an umbrella projects are not _completely_ decoupled. From [the docs](https://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-projects.html#dont-drink-the-kool-aid)

> While it provides a degree of separation between applications, those applications are not fully decoupled, as they are assumed to share the same configuration and the same dependencies.

And

> If you find yourself in a position where you want to use different configurations in each application for the same dependency or use different dependency versions, then it is likely your codebase has grown beyond what umbrellas can provide.

</details>

### Getting Started - creating an umbrella project

So far to create this repo, we first ran this command:

```sh
mix new ex_ample --umbrella
```

The name of the app is `ex_ample`, and the umbrella flag does exactly what you think it does.

### Adding to the umbrella

We added new individual apps to the umbrella project by running a command like this (from the root of the project):

```sh
cd apps && mix new app_name --sup
```

The `sup` flag stands for supervision, it just tells Mix to generate a [supervision tree](https://stackoverflow.com/questions/46554449/erlang-elixir-what-is-a-supervision-tree) automatically for us, instead of having to build one manually. More in [the docs 👩‍⚕️](https://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-projects.html)

We have added an app called `ex_ample_backend`. This will act as the datasource for our application. It has VERY limited capabilities. I don't recommend that you read the code unless you have a penchant for punishment. I certainly don't recomend you use it past this exercise.

### Adding a phoenix app

We have created a phoenix (web server) app called **graphql** using a command similar to this one:

```sh
cd apps && mix phx.new name_of_app --no-ecto --no-html
```

`--no-ecto` and `--no-html` flags are optional. The `--no-ecto` flag means Ecto files are not generated and the `--no-html` means no HTML views are generated (Ecto is a database wrapper for Elixir and as this example has no database, we don't need it.)

<details>
<summary>Wait, what is Phoenix?</summary>
<br/>
Phoenix is a web development framework written in Elixir which implements the server-side Model View Controller (MVC) pattern. Check out the docs here: https://hexdocs.pm/phoenix/overview.html#content. Phoenix is the top layer of a multi-layer system designed to be modular and flexible. The other layers include Cowboy, Plug and Ecto.
</details>

### Adding dependencies

We wanted to add 2 dependencies to this project:

- [Absinthe](https://github.com/absinthe-graphql/absinthe)
- [Absinthe Plug](https://github.com/absinthe-graphql/absinthe_plug)

<details>
<summary>What is Absinthe? Why are we adding it?</summary>
<br/>
Absinthe is the GraphQL toolkit for Elixir, built to suit Elixir's capabilities and style. With Absinthe, you define the schema and resolution functions and it executes GraphQL documents.

On client side Absinthe has support for Relay and Apollo client and in Elixir it uses Plug and Phoenix to support HTTP APIs, via `absinthe_plug` and `absinthe_phoenix` packages. It also has support for Ecto via the `absinthe_ecto package`.

</details>

Adding dependencies in elixir doesn't work like it does in javacript (`npm install jest` etc) - there are no magic words to install! We have added 2 dependencies manually in the `mix.exs` file inside the `graphql` app:

```elixir
{:absinthe, "~> 1.4.0"},
{:absinthe_plug, "~> 1.4.0"},
```

So the dependency section now looks like this:

```elixir
...
  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:absinthe, "~> 1.4.0"},
      {:absinthe_plug, "~> 1.4.0"},
      {:jason, "~> 1.1"},
      {:ex_ample_backend, in_umbrella: true},
      {:cors_plug, "~> 1.5"}
    ]
  end
end

```

### Adding web server routes

Inside our `router.ex` file in the graphql app, we've added 2 new routes. One is the route that Absinthe and Graphql use to host our GraphQL api (`/graphql`), the other is the route that the Graphiql tool uses (`/graphiql`), which is only available in development.

```elixir
  scope "/graphql" do
      forward(
        "/",
        Absinthe.Plug,
        schema: Graphql.Schema,
        json_codec: Jason
      )
    end

  if Mix.env() == :dev do
    forward(
      "/graphiql",
      Absinthe.Plug.GraphiQL,
      schema: Graphql.Schema,
      json_codec: Jason,
      default_url: "/graphiql",
      interface: :advanced
    )
  end
```

You don't need to worry too much about the syntax here, or remember it, its just for information!

### Adding a schema file and some smoke tests

We have added a `schema.ex` file and add a resolvers folder with a `resolver.ex` file in it.

Inside `schema.ex` we have defined the schema module, imported Absinthe, and written two 'hello world' smoke tests so we can check our api and resolvers are all working.

```elixir
defmodule Graphql.Schema do
  # This allows us to use the absinthe schema notation like 'query' and 'field'
  use Absinthe.Schema

  query do
    field :is_this_thing_on, type: :string do
      resolve(&Graphql.Resolver.smoke_test/2)
    end
  end

  mutation do
    field :echo_text, type: :string do
      arg(:input, :string)
      resolve(&Graphql.Resolver.test_update/2)
    end
  end
end
```

Inside `reslovers.ex` we added the two resolver functions from the schema.

```elixir
defmodule Graphql.Resolver do
  def smoke_test(_args, _info) do
    {:ok, "Yes!"}
  end

  def test_update(%{input: input}, _info) do
    {:ok, input}
  end
end
```

As you can see Absinthe `resolve` function (in the schema) expects resolver functions to return an "ok tuple" (or an "error tuple" in the case of an error), which is a tuple containing an ok or error atom and some data:

```elixir
# ok tuple (response is a variable that would contain some data)
{:ok, reponse}

# error tuple
{:error, response}
```

## Workshop Instructions

1. Clone this repo:

```sh
git clone https://github.com/developess/GraphQL-Workshop
```

2. Install Phoenix web framework if you don't have it already. You can find instructions [here](https://hexdocs.pm/phoenix/installation.html):

3. Fetch the dependencies for the repo by running:
   `mix deps.get`

4. Get your Phoenix server running:
   `mix phx.server`

If you go to `localhost:4000/graphiql` you should be able to see the Graphiql interface with the smoke tests above in the docs! Try writing a query or mutation that calls the smoke tests (Use the docs or the hint below).

<details>
<summary>Hint</summary>
<br/>
```graphql
query smokeTest {
  isThisThingOn
}
```
</details>

Then, checkout the next branch: `my-first-query` for your first challenge.
