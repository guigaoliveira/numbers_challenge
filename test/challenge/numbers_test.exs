defmodule NumbersTest do
  use ExUnit.Case

  alias Challenge.{Cache, Numbers}

  doctest Numbers

  @list_size 10

  test "should return a ordered list" do
    shuffled_list = Enum.shuffle(1..@list_size)

    Cache.delete_all()
    Cache.put(:extracted_numbers, shuffled_list)
    assert Numbers.all(%{order_by: "asc"}) == Enum.sort(shuffled_list)
  end

  test "should return a ordered list when order_by is not passed in argument" do
    shuffled_list = Enum.shuffle(1..@list_size)

    Cache.delete_all()
    Cache.put(:extracted_numbers, shuffled_list)
    assert Numbers.all() == Enum.sort(shuffled_list)
  end

  test "should return a reserve ordered list" do
    shuffled_list = Enum.shuffle(1..@list_size)

    Cache.delete_all()
    Cache.put(:extracted_numbers, shuffled_list)
    assert Numbers.all(%{order_by: "desc"}) == Enum.sort(shuffled_list, :desc)
  end
end
