# Quarry.Absinthe

[Absinthe](https://hex.pm/packages/absinthe) integration for [Quarry](https://hex.pm/packages/quarry), the data driven ecto query builder.

## Installation

Install from [Hex](https://hex.pm/package/quarry_asbinthe)
by adding `quarry_absinthe` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:quarry_absinthe, "~> 0.1.0"}
    {:quarry, "~> 0.2"}
  ]
end
```
While not a direct dependency, this package is made to work with [Quarry](https://hex.pm/packages/quarry), so you'll want to add that as a dependency as well

## Usage
In your `Schema` file, import the quarry types, and call the ExtractQuarryOpts middleware before the resolver function. This will analyize the graphQL query and generate paramaters that are compatible with Quarry's API.

```elixir
defmodule MyApp.Schema
  use Absinthe.Schema

  alias Quarry.Absinthe.Middleware.ExtractQuarryOpts

  import_types Quarry.Absinthe.Schema.FilterTypes

  query do
    field :posts, list_of(:post) do
      middleware ExtractQuarryOpts
      resolve MyApp.Resolvers.Post.list/2
    end
  end
end
```

In your resolver you can now pass the opts to your context function, build a query with Quarry, and exectute it.

```elixir
defmodule MyApp.Resolvers.Post do
  def list(_, %{context: %{quarry_opts: opts}}) do
    {:ok, MyApp.Posts.all(opts)}
  end
end
```
```elixir
defmodule MyApp.Posts do
  def all(opts \\ []) do
    opts
    |> Quarry.build()
    |> Repo.all()
  end
end
```


Docs can be found at [https://hexdocs.pm/quarry_absinthe](https://hexdocs.pm/quarry_absinthe).

