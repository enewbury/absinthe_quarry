defmodule Quarry.AbsintheTest do
  use ExUnit.Case
  doctest Quarry.Absinthe

  test "greets the world" do
    assert Quarry.Absinthe.hello() == :world
  end
end
