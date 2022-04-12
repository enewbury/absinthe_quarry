defmodule AbsintheQuarry.Middleware.QuarryErrors do
  @behaviour Absinthe.Middleware

  @impl Absinthe.Middleware

  def call(%{context: %{quarry_errors: errors}} = resolution, _) when length(errors) > 0 do
    cur_path = get_current_path(resolution)

    {current_errors, other_errors} =
      Enum.split_with(errors, fn
        %{load_path: path} -> path == cur_path
        %{type: :load, path: path} -> path == cur_path
      end)

    resolution = Map.update!(resolution, :context, &Map.put(&1, :quarry_errors, other_errors))
    put_result(resolution, current_errors)
  end

  def call(resolution, _) do
    resolution
  end

  defp get_current_path(resolution) do
    resolution.path
    |> Enum.reject(&is_number/1)
    |> Enum.map(fn %{schema_node: %{identifier: id}} -> id end)
    |> Enum.reverse()
    |> Enum.drop(2)
  end

  defp put_result(resolution, []) do
    resolution
  end

  defp put_result(resolution, errors) do
    messages = Enum.map(errors, & &1.message)
    Absinthe.Resolution.put_result(resolution, {:error, messages})
  end
end
