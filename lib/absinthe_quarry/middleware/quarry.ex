defmodule AbsintheQuarry.Middleware.Quarry do
  @moduledoc false

  alias AbsintheQuarry.Extract

  @behaviour Absinthe.Middleware

  @impl Absinthe.Middleware
  def call(resolution, {root_schema, repo}) do
    resolution
    |> Extract.run()
    |> then(&Quarry.build(root_schema, &1))
    |> build_result(resolution, repo)
  end

  defp build_result({query, []}, resolution, repo) do
    result = {:ok, repo.all(query)}
    Absinthe.Resolution.put_result(resolution, result)
  end

  defp build_result({_query, errors}, resolution, _repo) do
    quarry_field = resolution.definition.schema_node.identifier
    messages = Enum.map(errors, &format_error(&1, quarry_field))
    Absinthe.Resolution.put_result(resolution, {:error, messages})
  end

  defp format_error(%{type: :load, path: path, message: message}, quarry_field) do
    path = [quarry_field | path]
    "Invalid schema field \"#{Enum.join(path, ".")}\": #{message}"
  end

  defp format_error(error, quarry_field) do
    %{type: type, path: path, load_path: load_path, message: message} = error
    arg_path = [type | path]
    selection_path = [quarry_field | load_path]

    "Invalid schema argument \"#{Enum.join(arg_path, ".")}\" on field \"#{Enum.join(selection_path, ".")}\": #{message}"
  end
end
