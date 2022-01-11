defmodule Challenge.Worker do
  @moduledoc """
  Consumes an external API to get numbers
  """
  alias Challenge.{Cache, HTTPClient}

  require Logger

  @spec perform(Range.t() | nil, non_neg_integer) ::
          %{
            attempt: non_neg_integer,
            data: list,
            status: :ignore | :ok
          }
  def perform(window \\ config(:default_window), attempt \\ 0)

  def perform(window, attempt)
      when is_integer(attempt) and attempt >= 0 do
    %{data: extract_numbers(window), attempt: attempt, status: :ok}
  catch
    _, err ->
      retry_opts = %{
        max_retries: config(:max_retries) || 5,
        retry_delay: config(:retry_delay) || 100
      }

      Logger.debug(
        "New error for attempt #{attempt}, reason: #{Exception.format(:error, err, __STACKTRACE__)}."
      )

      new_attempt = attempt + 1
      delay = back_off(new_attempt, retry_opts[:retry_delay])

      Logger.debug("Retrying to extract numbers. Attempt #{attempt} with delay #{delay}.")

      perform(window, new_attempt, retry_opts[:max_retries])
  end

  defp perform(_, attempt, max_retries) when is_integer(attempt) and attempt >= max_retries,
    do: %{data: [], attempt: attempt, status: :ignore}

  defp perform(window, attempt, max_retries)
       when is_integer(attempt) and attempt < max_retries,
       do: perform(window, attempt)

  defp back_off(attempt, retry_delay) do
    delay = Integer.pow(2, attempt) * retry_delay
    Process.sleep(delay)
    delay
  end

  defp extract_numbers(window) do
    client = HTTPClient.new(url: "http://challenge.dienekes.com.br", compression: "gzip")

    numbers =
      client
      |> make_requests(window)
      |> tasks_results_to_list()

    Cache.put(:extracted_numbers, numbers)
    Cache.put(:updated_at, DateTime.utc_now())
    numbers
  end

  # with a fixed window we can make parallel and concurrent requests
  defp make_requests(client, _min.._max = window) do
    Challenge.TaskSupervisor
    |> Task.Supervisor.async_stream_nolink(
      window,
      &request_numbers_by_page(client, &1)
    )
    |> Stream.map(fn {:ok, {:ok, {numbers, _}}} ->
      numbers
    end)
  end

  # in case the last page is not known
  defp make_requests(client, nil) do
    client
    |> request_numbers_by_page(1)
    |> Stream.iterate(fn {_, {_, page}} -> request_numbers_by_page(client, page + 1) end)
    |> Stream.take_while(fn
      {:ok, {list, _}} when list != [] ->
        true

      {:ok, {[], _}} ->
        false
    end)
    |> Stream.map(fn {:ok, {numbers, _}} -> numbers end)
  end

  defp request_numbers_by_page(client, page) do
    delay_request = config(:delay_request) || 0

    if delay_request > 0 do
      Process.sleep(delay_request)
    end

    result = HTTPClient.request(client, url: "/api/numbers", method: :get, query: [page: page])

    case result do
      {:ok, %{body: %{"numbers" => numbers}}} -> {:ok, {numbers, page}}
      {:error, error} -> {:error, error}
    end
  end

  defp tasks_results_to_list(stream) do
    stream |> Enum.to_list() |> List.flatten()
  end

  defp config(key) do
    envs = Application.get_env(:challenge, __MODULE__)

    case Keyword.fetch(envs || [], key) do
      {:ok, value} -> value
      :error -> nil
    end
  end
end
