defmodule SortingTest do
  use ExUnit.Case

  alias Challenge.Sorting

  doctest Sorting

  @list_size 100

  test "should return a empty list" do
    assert Sorting.merge_sort([]) == []
  end

  test "should return sort a shuffled list" do
    shuffled_list = Enum.shuffle(1..@list_size)

    assert Sorting.merge_sort(shuffled_list) == Enum.sort(shuffled_list)
  end

  test "should return sort an ordered list" do
    ordered_list =
      1..@list_size
      |> Enum.shuffle()
      |> Enum.sort()

    assert Sorting.merge_sort(ordered_list) == ordered_list
  end

  test "should return sort an reverse ordered list" do
    reverse_ordered_list =
      1..@list_size
      |> Enum.shuffle()
      |> Enum.sort(:desc)

    assert Sorting.merge_sort(reverse_ordered_list) == Enum.sort(reverse_ordered_list)
  end

  test "should return sort a list containing duplicates" do
    ordered_list_with_duplicates =
      1..@list_size
      |> Enum.map(fn n -> replicate(5, n) end)
      |> List.flatten()
      |> Enum.shuffle()
      |> Enum.sort()

    assert Sorting.merge_sort(ordered_list_with_duplicates) == ordered_list_with_duplicates
  end

  def replicate(n, x), do: for(_ <- 1..n, do: x)
end
