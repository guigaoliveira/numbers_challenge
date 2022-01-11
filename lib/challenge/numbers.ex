defmodule Challenge.Numbers do
  @moduledoc """
  The Numbers Context
  """
  use Nebulex.Caching

  alias Challenge.{Cache, Sorting}

  @sort_ttl :timer.hours(1) * 24
  @sort_types [:asc, :desc]

  @doc """
  Returns a list of all numbers sorted (asc order is default)
  """
  @spec all(map) :: list | nil
  def all(attrs \\ %{}) do
    extracted_numbers = Cache.get(:extracted_numbers)

    transform(extracted_numbers, String.to_existing_atom(attrs[:order_by] || "asc"))
  rescue
    _ -> nil
  end

  defp transform(nil, _), do: nil

  defp transform(extracted_numbers, order)
       when is_list(extracted_numbers)
       when is_atom(order) and order in @sort_types do
    Cache.fetch({:sorted_numbers, order}, fn -> sort(extracted_numbers, order) end)
  end

  @decorate cacheable(cache: Cache, key: {list, order}, opts: [ttl: @sort_ttl])
  defp sort(list, order), do: Sorting.merge_sort(list, order)
end
