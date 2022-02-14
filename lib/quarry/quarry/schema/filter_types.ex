defmodule Quarry.Absinthe.Schema.FilterTypes do
  @moduledoc """
  Absinthe types for quarry

  `:operator` - All the possible operations for querying a value against a field
  `:string_filter` - Combines an operation with a string value
  `:integer_filter` - Combines an operation with an integer value
  """
  use Absinthe.Schema.Notation

  enum :operator do
    value(:eq)
    value(:lt)
    value(:lte)
    value(:gt)
    value(:gte)
    value(:starts_with)
    value(:ends_with)
  end

  input_object :string_filter do
    field(:op, :operator)
    field(:value, :string)
  end

  input_object :integer_filter do
    field(:op, :operator)
    field(:value, :integer)
  end
end
