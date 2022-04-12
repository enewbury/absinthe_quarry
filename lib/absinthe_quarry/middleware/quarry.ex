defmodule AbsintheQuarry.Middleware.Quarry do
  alias AbsintheQuarry.Extract

  @behaviour Absinthe.Middleware

  @impl Absinthe.Middleware
  def call(resolution, {root_schema, repo}) do
    resolution
    |> Extract.run()
    |> then(&Quarry.build(root_schema, &1))
    |> handle_errors(resolution)
    |> build_result(repo)
  end

  defp handle_errors({query, errors}, resolution) do
    {errors, nested_errors} = Enum.split_with(errors, &match?(%{load_path: []}, &1))

    resolution = %{
      resolution
      | context: Map.put(resolution.context, :quarry_errors, nested_errors)
    }

    {query, errors, resolution}
  end

  def build_result({query, [], resolution}, repo) do
    result = {:ok, repo.all(query)}
    Absinthe.Resolution.put_result(resolution, result)
  end

  def build_result({_query, errors, resolution}, _repo) do
    messages = Enum.map(errors, & &1.message)
    Absinthe.Resolution.put_result(resolution, {:error, messages})
  end
end
