defmodule AbsintheQuarry.Comment do
  use Ecto.Schema

  schema "comments" do
    field :message, :string

    belongs_to :user, AbsintheQuarry.User
    belongs_to :post, AbsintheQuarry.Post
  end
end
