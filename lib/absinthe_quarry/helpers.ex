defmodule AbsintheQuarry.Helpers do
  @moduledoc """
  Functions to integrate quarry with your absinthe schema
  """

  alias AbsintheQuarry.Middleware

  @doc """
  Returns a resolver function that runs a quarry query.

  ```elixir
  field :posts, list_of(:post), resolve: quarry(Post, Repo)
  ```

  This resolver will use arguments `filter`, `sort`, `limit`, and `offset` and apply them to the quarry options.

  ```elixir
  field :posts, list_of(:post), resolve: quarry(Post, Repo) do
    arg :filter, :post_filter
    arg :sort, :post_sort
    arg :limit, :integer
    arg :offset, :ineger
  end
  ```

  The resolver will check any selected fields and prelaod them if the appropriate meta tag is specified


  ```elixir
  object :post do
    field :author, :author, meta: [qurry: true]
  end

  ...

  field :posts, list_of(:post), resolve: quarry(Post, Repo)

  ```

  Note, has_many sub fields will also be checked for the quarry args, see README for details


  ```elixir
  object :post do
    field :comments, :comment, meta: [qurry: true] do
      arg :filter, :comment_filter
    end
  end

  ...

  field :posts, list_of(:post), resolve: quarry(Post, Repo)
  ```

  The double underscore `__` will indicate to quarry the value to the left is the field name
  and the value to the right is the quarry operator.

  ```elixir
    input_object :user do
      field :name__starts_with, :string
    end
  ```

  The double underscore in sort enums will also indicate a separation of fields so that you can sort on sub fields
  ```elixir
  enum :post_sort do
    value :title
    value :user__name
  end
  ```
  """
  @type quarry_tuple :: {:middleware, Middleware.Quarry, term}
  @type quarry_key_fun ::
          (Absinthe.Resolution.source(),
           Absinthe.Resolution.arguments(),
           Absinthe.Resolution.t() ->
             quarry_tuple())

  @spec quarry(atom(), Ecto.Repo.t()) :: quarry_key_fun()
  def quarry(root_schema, repo) do
    fn _, _, _ ->
      {:middleware, Middleware.Quarry, {root_schema, repo}}
    end
  end
end
