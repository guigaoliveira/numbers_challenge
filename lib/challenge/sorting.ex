defmodule Challenge.Sorting do
  @moduledoc """
  Implements sorting algoritms
  """

  defp merge([], list, _), do: list
  defp merge(list, [], _), do: list

  defp merge([head1 | tail1] = list1, [head2 | tail2] = list2, fun) do
    if fun.(head1, head2) do
      [head1 | merge(tail1, list2, fun)]
    else
      [head2 | merge(list1, tail2, fun)]
    end
  end

  @doc """
  Sorts a `list` by the given function using merge sort algorithm.
  The given function should compare two arguments, and return true if the first argument precedes or is in the same place as the second one.
  This function allows a developer to pass :asc or :desc as the sorting function, which is a convenience for <=/2 and >=/2 respectively.
  """
  @spec merge_sort(list, atom | fun) :: list
  def merge_sort(list, fun \\ :asc)
  def merge_sort(list, _) when length(list) <= 1, do: list

  def merge_sort(list, fun) when is_list(list) and is_function(fun, 2) do
    {left, right} = Enum.split(list, div(length(list), 2))
    merge(merge_sort(left, fun), merge_sort(right, fun), fun)
  end

  def merge_sort(list, :asc), do: merge_sort(list, &<=/2)
  def merge_sort(list, :desc), do: merge_sort(list, &>=/2)
end
