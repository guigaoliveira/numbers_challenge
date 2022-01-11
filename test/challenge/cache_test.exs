defmodule CacheTest do
  use ExUnit.Case

  alias Challenge.Cache

  doctest Cache

  @list_size 10

  test "should execute fallback function and insert a list in cache" do
    list = Enum.shuffle(1..@list_size)

    assert Cache.get(:numbers) == nil
    assert Cache.fetch(:numbers, fn -> list end) == list
    assert Cache.fetch(:numbers, nil) == list
  end
end
