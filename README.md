# Absinthe Quarry

[![Build Status](https://github.com/enewbury/absinthe_quarry/workflows/test/badge.svg)](https://github.com/enewbury/absinthe_quarry/actions)
[![Coverage Status](https://coveralls.io/repos/enewbury/absinthe_quarry/badge.svg?branch=main)](https://coveralls.io/r/enewbury/absinthe_quarry?branch=main)
[![hex.pm version](https://img.shields.io/hexpm/v/absinthe_quarry.svg)](https://hex.pm/packages/absinthe_quarry)
[![hex.pm license](https://img.shields.io/hexpm/l/absinthe_quarry.svg)](https://github.com/enewbury/absinthe_quarry/blob/main/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/enewbury/absinthe_quarry.svg)](https://github.com/enewbury/absinthe_quarry/commits/main)
<!-- [![hex.pm downloads](https://img.shields.io/hexpm/dt/absinthe_quarry.svg)](https://hex.pm/packages/absinthe_quarry) -->

[Absinthe](https://hex.pm/packages/absinthe) integration for [Quarry](https://hex.pm/packages/quarry), the data driven ecto query builder.

## Installation

Install from [Hex](https://hex.pm/package/absinthe_quarry)
by adding `absinthe_quarry` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_quarry, "~> 0.0.1"}
    {:quarry, "~> 0.3.1"}
  ]
end
```
While not a direct dependency, this package is made to work with [Quarry](https://hex.pm/packages/quarry), so you'll want to add that as a dependency as well
## Background
Check out this blog post for the 10,000ft view of why and how this package is useful for building upon where dataloader leaves off.

https://blog.testdouble.com/posts/2022-04-26-graphql-made-easy-elixir/

## Usage

### Filtering
Add a `filter` arg to the field using quarry, and define an input object with any fields of that entity, as well as any association of that entity, and quarry will automatically build the appropriate query.

```elixir
defmodule App.Schema
  use Absinthe.Schema
  import AbsintheQuarry.Helpers, only: [quarry: 2]

  input_object :post_filter do
    field :title, :string
    field :author, :author_filter
  end

  input_object :author_filter do
    field :name, :string
  end

  object :post do
    field :title
  end

  query do
    field :posts, list_of(:post), resolve: quarry(App.Post, App.Repo) do
      arg :filter, :post_filter
    end
  end
end
```
Now you can make queries like this:
```graphql
query {
  posts(title: "How To", author: {name: "John"}) { title }
}
```
Note: if the `author` association doesn't exist on a `Post` entity, an error will be returned.
Future iterations of `absinthe_quarry` will allow setting an `association` parameter to fields to override using the default name.

You can also set add a `__` suffix to a filter field to use a different operator than equality. for example, to check for a post whose title starts with "How To" you could use
```graphql
query {
  posts(title__startsWith: "How To") { title }
}
```

Check the `quarry` docs for all the available operators

### Sorting
`absinthe_quarry` allows you to add a `sort` argument to the quarried field, to sort by any field on the entity or field on an association

```elixir
defmodule App.Schema
  use Absinthe.Schema
  import AbsintheQuarry.Helpers, only: [quarry: 2]

  enum :post_sort do
    value :title
    value :author__name
  end

  object :post do
    field :title
  end

  query do
    field :posts, list_of(:post), resolve: quarry(App.Post, App.Repo) do
      arg :sort, :post_sort
    end
  end
end
```
Now you can make queries sorting by associated fields and quarry will do the joins as needed

```graphql
query {
  posts(sort: AUTHOR__NAME) { title }
}
```

`absinthe_quarry` also supports taking a list of fields as sort

```elixir
arg :sort, list_of(:post_sort)
```
```graphql
{ posts(sort: [TITLE, AUTHOR__NAME]) { title } }
```
However, because the graphql spec doesn't support input union types, your sort field can only support single, or a list of fields, but not either.  It may be best for now to always make it a list to be flexible.
Future iterations of `absinthe_quarry` will allow setting an `quarry_arg: "sort"` override on the arg, so you could have two sort args, one called `sortBy` and another `sortAll` and AbsinthQuarry would parse them both as a `quarry` "sort" option.
While `quarry` supports sorting by `asc` or `desc`, this functionality isn't yet implemented in the abinsthe integration. PR's welcome ;)

### Loading
Dataloader is a very powerful and mature library, so there is nothing wrong with using that for handling your batched loading of data.  It does have one drawback though, which is that even for `belongs_to` associations where it would be more efficient to simply join in that data in the original query, dataloader makes a separate query for each entity type.  This certainly isn't bad, but as long as you are using `quarry` you can get most of the same functionality as dataloader, with the added benefit of fetching belongs_to associations with a preload ahead of time.  Note: has_many associations will be selected with a subquery, since it is generally considered better to make a separate query than load in n*m records into memory.

To denote that you'd like quarry to preload a field, simply add a meta tag `quarry: true`, and `absinthe_quarry` will preload in that field as long as there is a matching association for that field name.  This means, you can also add your own resolver, and the "parent" arg of the resolver will already be ready for you, and you can process it as needed before finally resolving it. You can also override the association name, so you could do something like:
```elixir
field :author_name, meta: [quarry: [assoc: :author]], resolve: fn %{name: name}, _, _ -> name end
```

Additionally. on has_many association fields, you can add local filtering/sorting/limits etc just like you do at the top level resolver. So if you wanted to select posts and their comments,
but only show the first 2 comments with more than 10 likes, you could do something like:
```elixir
input_object :comment_filter do
  field :likes__gte, :integer
end

object :comment do
  field :message, :string
end

object :post do
  field :title
  field :comments, list_of(:comment), meta: [quarry: true] do
    arg :filter, :comment_filter
    arg :limit, :integer
  end
end

query do
  field :posts, list_of(:post), resolve: quarry(App.Post, App.Repo)
end
```
```graphql
query {
  posts {
    title
    comments(filter: {likes__gte: 10}, limit: 2) {
      message
    }
  }
}
```
Docs can be found at [https://hexdocs.pm/absinthe_quarry](https://hexdocs.pm/absinthe_quarry).
