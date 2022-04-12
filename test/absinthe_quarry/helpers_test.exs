defmodule AbsintheQuarry.HelpersTest do
  use AbsintheQuarry.DataCase

  import AbsintheQuarry.Factory

  defmodule Schema do
    use Absinthe.Schema

    alias AbsintheQuarry.Repo
    alias AbsintheQuarry.Post

    import AbsintheQuarry.Helpers, only: [quarry: 2]

    input_object :comment_filter do
      field :message, :string
      field :fake, :fake_filter
    end

    input_object :user_filter do
      field :name, :string
      field :fake, :fake_filter
    end

    input_object :fake_filter do
      field :field, :string
    end

    input_object :post_filter do
      field :title, :string
      field :title__starts_with, :string
      field :views, :integer
      field :views__lt, :integer
      field :user, :user_filter
      field :fake, :fake_filter
    end

    enum :post_sort do
      value :title
      value :views
      value :user__name
    end

    object :comment do
      field :message, :string
      field :post, :post, meta: [quarry: true]
      field :user, :user, meta: [quarry: true]
    end

    object :user do
      field :name, :string
      field :posts, list_of(:post), meta: [quarry: true]

      field :comments, list_of(:comment), meta: [quarry: true] do
        arg :filter, :comment_filter
      end
    end

    object :post do
      field :title, :string
      field :views, :integer
      field :user, :user, meta: [quarry: true]
      field :fake, :fake, meta: [quarry: true]

      field :comments, list_of(:comment), meta: [quarry: true] do
        arg :filter, :comment_filter
      end
    end

    object :fake do
      field :field, :string
    end

    query do
      field :posts, list_of(:post) do
        arg :filter, :post_filter
        arg :sort, :post_sort
        arg :limit, :integer
        arg :offset, :integer
        resolve quarry(Post, Repo)
      end
    end

    def middleware(middleware, _, _) do
      [AbsintheQuarry.Middleware.QuarryErrors | middleware]
    end
  end

  test "can load" do
    insert(:comment, message: "hi", post: insert(:post, user: insert(:user, name: "John")))

    query = "{ posts { user { name }, comments { message } } }"

    assert %{data: data} = Absinthe.run!(query, Schema)

    assert %{"posts" => [%{"comments" => [%{"message" => "hi"}], "user" => %{"name" => "John"}}]} ==
             data
  end

  test "can filter top level" do
    insert(:post, title: "post 1")
    insert(:post, title: "post2")

    query = "{ posts(filter: {title: \"post2\"}) { title }}"
    assert %{data: %{"posts" => [%{"title" => "post2"}]}} = Absinthe.run!(query, Schema)
  end

  test "can filter nested" do
    insert(:post, user: insert(:user, name: "name1"))
    insert(:post, user: insert(:user, name: "name2"))

    query = "{ posts(filter: {user: { name: \"name1\"}}) { user { name } }}"

    assert %{data: %{"posts" => [%{"user" => %{"name" => "name1"}}]}} =
             Absinthe.run!(query, Schema)
  end

  test "can filter sub list" do
    post = insert(:post)
    insert(:comment, post: post, message: "first")
    insert(:comment, post: post, message: "second")

    query = "{ posts { comments(filter: {message: \"first\"}) { message}}}"

    assert %{data: %{"posts" => [%{"comments" => [%{"message" => "first"}]}]}} =
             Absinthe.run!(query, Schema)
  end

  test "can filter using operator suffix" do
    insert(:post, title: "post1", views: 5)
    insert(:post, title: "post2", views: 10)

    query = "{ posts(filter: {views__lt: 8}) { title }}"
    assert %{data: %{"posts" => [%{"title" => "post1"}]}} = Absinthe.run!(query, Schema)
  end

  test "can sort by top level" do
    insert(:post, views: 5)
    insert(:post, views: 10)
    insert(:post, views: 3)

    query = "{ posts(sort: VIEWS) { views }}"

    assert %{data: %{"posts" => [%{"views" => 3}, %{"views" => 5}, %{"views" => 10}]}} =
             Absinthe.run!(query, Schema)
  end

  test "can sort by nested" do
    insert(:post, user: insert(:user, name: "5"))
    insert(:post, user: insert(:user, name: "8"))
    insert(:post, user: insert(:user, name: "3"))

    query = "{ posts(sort: USER__NAME) { user { name } }}"

    assert %{
             data: %{
               "posts" => [
                 %{"user" => %{"name" => "3"}},
                 %{"user" => %{"name" => "5"}},
                 %{"user" => %{"name" => "8"}}
               ]
             }
           } = Absinthe.run!(query, Schema)
  end

  # TODO: can sort by desc

  test "returns error on invalid selection" do
    insert(:comment, message: "hi", post: insert(:post, user: insert(:user, name: "John")))

    query = "{ posts { fake { field } } }"

    assert %{errors: [error]} = Absinthe.run!(query, Schema)
    assert %{path: ["posts", 0, "fake"]} = error
  end

  test "returns error on only the matching field" do
    insert(:comment, message: "hi", post: insert(:post, user: insert(:user, name: "John")))

    query = "{ posts { user { name }, fake { field } } }"

    assert %{data: %{"posts" => [%{"user" => %{"name" => "John"}}]}, errors: [error]} =
             Absinthe.run!(query, Schema)

    assert %{path: ["posts", 0, "fake"]} = error
  end

  test "returns error on invalid filter selection" do
    query = """
    {
      posts(filter: { fake: {field: \"hi\"}}) {
        fake { field },
        comments(filter: { fake: {field: \"hi\"}}) {
          message
        }
      }
    }
    """

    assert %{errors: [%{path: ["posts"]}]} = Absinthe.run!(query, Schema)
  end

  test "returns error on filter within has_many" do
    insert(:comment, message: "hi", post: insert(:post, user: insert(:user, name: "John")))

    query = "{ posts { user { comments(filter: {fake: {field: \"val\"}}) { message } }} }"

    assert %{errors: [error]} = Absinthe.run!(query, Schema)

    assert %{path: ["posts", 0, "user", "comments"]} = error
  end
end
