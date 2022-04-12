defmodule AbsintheQuarry.ExtractTest do
  use ExUnit.Case

  defmodule Schema do
    use Absinthe.Schema
    alias AbsintheQuarry.Extract

    input_object :child_filter do
      field :field1, :string
    end

    input_object :parent_filter do
      field :child, :child_filter
      field :field1, :string
      field :field1__starts_with, :string
      field :field2__lt, :integer
    end

    enum :parent_sort do
      value :field1
      value :child__field1
    end

    enum :child_sort do
      value :field1
      value :grandchild__field1
    end

    object :parent do
      field :field1, :string

      field :child, :child, meta: [quarry: true]

      field :children, list_of(:child), meta: [quarry: true] do
        arg :filter, :child_filter
        arg :sort, list_of(:child_sort)
      end
    end

    object :child do
      field :field1, :string
      field :grandchild, :grandchild, meta: [quarry: true]
    end

    object :grandchild do
      field :field1, :string
    end

    query do
      field :parents, list_of(:parent) do
        arg :filter, :parent_filter
        arg :sort, :parent_sort
        arg :limit, :integer
        arg :offset, :integer

        resolve(fn _, info ->
          params = Extract.run(info)
          send(self(), params)
          {:ok, nil}
        end)
      end
    end
  end

  test "loads a child object" do
    query = "query { parents { child { field1 } } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive load: [child: []]
  end

  test "loads a grandchild object" do
    query = "query { parents { child { grandchild { field1 } } } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive load: [child: [grandchild: []]]
  end

  test "extracts args on top level field" do
    query = "query { parents(filter: {field1: \"test\"}) {  field1 } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive filter: %{field1: "test"}
  end

  test "extracts args from fuzzy filters" do
    query = "query { parents(filter: {field1__startsWith: \"test\", field2__lt: 2}) {  field1 } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive filter: %{field1: {:starts_with, "test"}, field2: {:lt, 2}}
  end

  test "extracts args on nested field" do
    query = "query { parents(filter: { child: { field1: \"test\" } }) {  field1 } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive filter: %{child: %{field1: "test"}}
  end

  test "can sort by single field" do
    query = "query { parents(sort: CHILD__FIELD1) { field1 } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive sort: [[:child, :field1]]
  end

  test "can sort by multiple fields" do
    query = "query { parents{ children(sort: [FIELD1, GRANDCHILD__FIELD1]) { field1 } } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive load: [children: [sort: [[:field1], [:grandchild, :field1]]]]
  end

  test "can limit and offset" do
    query = "query { parents(limit: 10, offset: 2) {  field1 } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive limit: 10, offset: 2
  end

  test "can filter the sub selection" do
    query = "query { parents { children(filter: { field1: \"test\"}) { field1 } } }"
    assert {:ok, %{data: _}} = Absinthe.run(query, Schema)
    assert_receive load: [children: [filter: %{field1: "test"}]]
  end
end
