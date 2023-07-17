defmodule AbsintheQuarry.Phase.AssociationExists do
  use Absinthe.Phase

  alias Absinthe.Blueprint
  alias Absinthe.Blueprint.Schema.{SchemaDefinition, FieldDefinition}
  alias Absinthe.Blueprint.TypeReference

  @impl true
  def run(bp, _opts) do
    bp = Blueprint.prewalk(bp, &handle_schemas/1)
    {:ok, bp}
  end

  defp handle_schemas(%SchemaDefinition{} = schema) do
    types = Map.new(schema.type_definitions, &{&1.identifier, &1})

    schema = Blueprint.prewalk(schema, &validate(&1, types))
    {:halt, schema}
  end

  defp handle_schemas(obj), do: obj

  defp validate(%FieldDefinition{flags: %{quarry_root: ecto_schema}} = entity, types) do
    IO.inspect(entity, label: "ENTITY FOUND")
    type = TypeReference.unwrap(entity.type)
    root_object = Map.get(types, type)
    context = %{ecto_schema: ecto_schema, path: [], root_ecto_schema: ecto_schema, types: types}
    validate_associations(root_object, context)
  end

  defp validate(%FieldDefinition{flags: %{reserved_name: true}} = entity, _types), do: entity

  defp validate(%FieldDefinition{flags: flags} = entity, _types) when map_size(flags) > 0 do
    IO.inspect(entity, label: "ENTITY WITH FLAGS")
  end

  defp validate(obj, _types), do: obj

  defp validate_associations(%{fields: fields} = obj, ctx) do
    # validated_fields = Enum.map(fields, &validate_assoc(&1, ctx))
    # Map.put(obj, :fields, validated_fields)
    obj
  end

  defp validate_associations(obj, _ctx), do: obj

  defp validate_assoc(
         %{flags: %{quarry_assoc: assoc}} = field,
         %{ecto_schema: schema, types: types} = ctx
       ) do
    case schema.__schema__(:association, assoc) do
      %{queryable: child_schema} ->
        child_object = field.type |> TypeReference.unwrap() |> then(&Map.get(types, &1))

        if Map.has_key?(child_object, :fields),
          do:
            validate_associations(child_object, %{
              ctx
              | ecto_schema: child_schema,
                path: [assoc | ctx.path]
            }),
          else: field

      _ ->
        put_error(field, error(field.__reference__.location, %{ctx | path: [assoc | ctx.path]}))
    end
  end

  defp validate_assoc(field, _ctx), do: field

  defp error(location, data) do
    %Absinthe.Phase.Error{
      message: explanation(data),
      locations: [location],
      phase: __MODULE__,
      extra: data
    }
  end

  @moduledoc false

  @description """
  `assocation` macros must have a matching identifier to the parent quarry schema
  """

  def explanation(%{ecto_schema: schema, root_ecto_schema: root_schema, path: [assoc | _] = path}) do
    """
    #{inspect(assoc)} is not a valid assocation on schema #{inspect(schema)} which
    was loaded through #{inspect(root_schema)}.#{path |> Enum.reverse() |> Enum.join(".")}

    #{@description}
    """
  end
end
