defmodule Quarry.Absinthe.Middleware.ExtractQuarryOpts do
  @moduledoc """
  Middleware that extracts data from the Absinthe query, builds quarry opts, and saves it on the context

  After this middleware has run, resolvers should be able to access `quarry_opts` on the resolution context
  """
  @behaviour Absinthe.Middleware

  @typedoc """
  `no_default_suffix`: default `false`, Doesn't trim `Where` off the end of field names
  `default_suffix`: default `where`, Set the suffix to trim off the the of field names, i.e. if you want valueBy: {op: GT, value: 2} you can set `default_suffix` to "by"
  `assoc_mappings`: default `%{}`, allows explicitly mapping field names to their ecto associations, i.e. `%{view: :impressions}` will now look for ecto associations named :imporessions instead of :views
  """
  @type opts :: [no_default_suffix: boolean(), default_suffix: String.t(), assoc_mappings: map()]
  @doc """
  Adds `quarry_opts` to resolution context, based on analyzing the absinthe query

  By default fields with the suffix `Where` will be converted to ecto qssociations with the `Where` removed.
  This is useful if you would like a simple field for filtering by equality, i.e. `clicks: 30` but also want
  a field for querying by more complex operations, i.e. clicksWhere: {op: LT, 30}` for clicks less than 30.
  """
  @impl true
  @spec call(Absinthe.Resolution.t(), opts()) :: Absinthe.Resolution.t()
  def call(resolution, opts) do
    no_default = Keyword.get(opts, :no_default_suffix, false)
    suffix = Keyword.get(opts, :default_suffix, "where")
    assoc_mappings = Keyword.get(opts, :assoc_mappings, %{})

    fields = Absinthe.Resolution.project(resolution)

    quarry_opts =
      extract_opts(resolution.arguments, fields,
        no_default: no_default,
        suffix: suffix,
        assoc_mappings: assoc_mappings
      )

    context = Map.put(resolution.context, :quarry_opts, quarry_opts)
    %{resolution | context: context}
  end

  defp extract_opts(args, fields, opts) when map_size(args) == 0 do
    extract_loads(fields, opts)
  end

  defp extract_opts(args, fields, opts) do
    args
    |> Map.update(:filter, %{}, &normalize_args(&1, opts))
    |> Map.put(:load, extract_loads(fields, opts))
    |> Keyword.new()
  end

  defp extract_loads(fields, opts) do
    fields
    |> Enum.filter(&(Enum.count(&1.selections) > 0))
    |> Enum.map(fn field ->
      %{
        schema_node: %{identifier: field_name},
        argument_data: args,
        selections: sub_fields
      } = field

      {get_canonical_name(field_name, opts), extract_opts(args, sub_fields, opts)}
    end)
  end

  defp normalize_args(args, opts) do
    args
    |> Enum.map(fn
      {field, %{op: op, value: value}} ->
        {get_canonical_name(field, opts), {op, value}}

      {field, child} when is_map(child) ->
        {get_canonical_name(field, opts), normalize_args(child, opts)}

      {field, value} ->
        {get_canonical_name(field, opts), value}
    end)
    |> Map.new()
  end

  defp get_canonical_name(field, no_default: no_default, suffix: suffix, assoc_mappings: mappings) do
    case Map.get(mappings, field) do
      nil -> trim_field_suffix(field, suffix, no_default)
      _ -> field
    end
  end

  defp trim_field_suffix(field, _suffix, true), do: field

  defp trim_field_suffix(field, suffix, _) do
    field
    |> Atom.to_string()
    |> String.trim_trailing("_#{suffix}")
    |> String.to_existing_atom()
  rescue
    _ -> field
  end
end
