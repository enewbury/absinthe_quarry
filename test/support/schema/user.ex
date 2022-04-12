defmodule AbsintheQuarry.User do
  use Ecto.Schema

  schema "users" do
    field :name, :string

    has_many :comments, AbsintheQuarry.Comment
    has_many :posts, AbsintheQuarry.Post
  end
end
