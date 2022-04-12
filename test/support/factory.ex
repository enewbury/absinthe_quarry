defmodule AbsintheQuarry.Factory do
  use ExMachina.Ecto, repo: AbsintheQuarry.Repo

  def post_factory do
    %AbsintheQuarry.Post{
      title: sequence(:title, &"Post #{&1}"),
      views: 1,
      user: build(:user)
    }
  end

  def comment_factory do
    %AbsintheQuarry.Comment{
      message: sequence("comment"),
      user: build(:user),
      post: build(:post)
    }
  end

  def user_factory do
    %AbsintheQuarry.User{
      name: sequence("John Doe")
    }
  end
end
