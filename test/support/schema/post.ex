defmodule AbsintheQuarry.Post do
  use Ecto.Schema

  schema "posts" do
    field :title, :string
    field :views, :integer

    belongs_to :user, AbsintheQuarry.User
    has_many :comments, AbsintheQuarry.Comment
  end
end
