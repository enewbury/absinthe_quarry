defmodule AbsintheQuarry.Notation do
  import Absinthe.Schema.Notation, only: [field: 2]

  defmacro root_field(identifier, type, ecto_schema) do
    schema = Macro.expand(ecto_schema, __CALLER__)

    quote do
      field unquote(identifier), unquote(type), unquote(add_flags(%{quarry_root_schema: schema}))
    end
  end

  defmacro association(identifier, attrs) when is_list(attrs) do
    quote do
      field unquote(identifier), unquote(add_assoc_flags(identifier, attrs))
    end
  end

  defmacro association(identifier, type) do
    quote do
      field unquote(identifier), unquote(type), unquote(add_assoc_flags(identifier))
    end
  end

  defmacro association(identifier, attrs, do: block) when is_list(attrs) do
    quote do
      field unquote(identifier), unquote(add_assoc_flags(identifier, attrs)), do: unquote(block)
    end
  end

  defmacro association(identifier, type, do: block) do
    quote do
      field unquote(identifier), unquote(type), unquote(add_assoc_flags(identifier)),
        do: unquote(block)
    end
  end

  defmacro association(identifier, type, attrs) do
    quote do
      field unquote(identifier), unquote(type), unquote(add_assoc_flags(identifier, attrs))
    end
  end

  defmacro association(identifier, type, attrs, do: block) do
    quote do
      field unquote(identifier), unquote(type), unquote(add_assoc_flags(identifier, attrs)),
        do: unquote(block)
    end
  end

  # defmacro field(identifier, attrs) when is_list(attrs) do
  #   IO.puts("Using my special thing")

  #   quote do
  #     Absinthe.Schema.Notation.field(unquote(identifier), unquote(attrs))
  #   end
  # end

  defp add_assoc_flags(ident, attrs \\ []) do
    add_flags(%{quarry_association: ident}, attrs)
  end

  defp add_flags(flags, attrs \\ []) do
    Keyword.put(attrs, :flags, flags)
  end
end
