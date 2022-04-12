defmodule AbsintheQuarry.Repo.Migrations.AddPostsTable do
  use Ecto.Migration

  def change do
    create table("posts") do
      add :title, :string
      add :views, :integer
      add :user_id, references(:users)
    end
  end
end
