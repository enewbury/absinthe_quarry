defmodule DslSchema do
  use Absinthe.Schema

  alias AbsintheQuarry.Post
  alias AbsintheQuarry.Author

  @pipeline_modifier AbsintheQuarry.PipelineModifier

  object :user do
    field :name, :string
    field :special_thing, :string
  end

  object :author do
    field :rating, :integer
    field :user, :user, flags: %{quarry_assoc: :user}
    field :user_name, :string, flags: %{quarry_assoc: :uger}, resolve: & &1.name
  end

  object :comment do
    field :text, :string
    field :author, :author, flags: %{quarry_assoc: :author}
  end

  object :post do
    field :comments, list_of(:comment), flags: %{quarry_assoc: :comments}
  end

  query do
    field :posts, list_of(:post), flags: %{quarry_root: Post}
    field :authors, list_of(:author), flags: %{quarry_root: Author}
  end
end

# Error: association uger does not exist on AbsintheQuarry.Author

# Quarry load path is:
#   posts: AbsintheQuarry.Post
#     > posts.comments: AbsintheQuary.Post.comments
#     > posts.comments.author: AbsintheQuarry.Comment.author
