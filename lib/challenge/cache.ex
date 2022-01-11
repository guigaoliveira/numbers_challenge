defmodule Challenge.Cache do
  @moduledoc """
  In-memory and distributed cache
  """
  use Nebulex.Cache,
    otp_app: :challenge,
    adapter: Nebulex.Adapters.Local

  alias Challenge.Cache

  @doc """
  Fetches an entry from a cache, generating a value on cache miss.
  A `fallback` function is a function used to generate a value to place inside a cache on miss.
  """
  @spec fetch(term, fun | nil, Keyword.t()) :: term
  def fetch(key, fallback \\ nil, opts \\ []) when is_nil(fallback) or is_function(fallback, 0) do
    Cache.transaction(fn ->
      case Cache.get(key) do
        nil when is_function(fallback, 0) ->
          value = fallback.()
          Cache.put(key, value, opts)
          value

        value ->
          value
      end
    end)
  end
end
