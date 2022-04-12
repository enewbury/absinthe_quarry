defmodule AbsintheQuarry.Helpers do
  alias AbsintheQuarry.Middleware

  def quarry(root_schema, repo) do
    fn _, _, _ ->
      {:middleware, Middleware.Quarry, {root_schema, repo}}
    end
  end
end
