defmodule Challenge.HTTPClient do
  @moduledoc """
  Http Client
  """

  require Logger

  @typedoc """
  Possible error reasons.
  """
  @type error_reason ::
          :bad_request
          | :unauthenticated
          | :unauthorized
          | :not_found
          | :unprocessable_entity
          | :client_error
          | :server_error
          | :unexpected_return
          | :unauthorized

  @typedoc """
  Possible bodies in an HTTP response.
  """
  @type body ::
          %{required(String.t()) => body() | nil}
          | list(body())
          | number()
          | boolean()
          | String.t()

  @typedoc """
  Success response.
  """
  @type success_response() :: %{
          body: body,
          headers: [{binary, binary}],
          status: integer | nil
        }

  @typedoc """
  All types of HTTP call returns.
  """
  @type http_return ::
          {:ok, success_response()}
          | {:error, {error_reason(), body()} | :unexpected_return | error_reason()}

  defguardp is_redirect(status) when is_integer(status) and status >= 300 and status < 400
  defguardp is_client_error(status) when is_integer(status) and status >= 400 and status < 500
  defguardp is_server_error(status) when is_integer(status) and status >= 500
  defguardp is_success(status) when is_integer(status) and status >= 200 and status < 300

  @spec new(Keyword.t()) :: Tesla.Client.t()
  def new(opts \\ []) do
    middlewares = [
      {Tesla.Middleware.BaseUrl, opts[:url] || ""},
      {Tesla.Middleware.Compression, format: opts[:compression] || "gzip"},
      Tesla.Middleware.JSON,
      Tesla.Middleware.KeepRequest,
      Tesla.Middleware.Telemetry,
      Tesla.Middleware.Logger,
      {Tesla.Middleware.Retry,
       should_retry: fn
         {:ok, %{status: status}} when status in 500..599 -> true
         {:ok, _} -> false
         {:error, _} -> true
       end}
    ]

    adapter = {Tesla.Adapter.Finch, name: Finch}
    Tesla.client(middlewares, adapter)
  end

  @spec request(Tesla.Client.t(), [{:body | :headers | :method | :opts | :query | :url, any}]) ::
          http_return()
  def request(client, request_opts) do
    client
    |> Tesla.request(request_opts)
    |> parse_result()
  end

  defp parse_result(result)

  defp parse_result({:ok, %{status: status} = env}) when is_success(status) do
    {:ok, %{body: env.body, headers: env.headers, status: status}}
  end

  defp parse_result({:ok, %{status: 400, body: body}}) do
    Logger.warn("Bad request. Body: #{inspect(body)}")
    {:error, {:bad_request, body}}
  end

  defp parse_result({:ok, %{status: 422, body: body}}) do
    Logger.warn("Unprocessable entity. Body: #{inspect(body)}")
    {:error, {:unprocessable_entity, body}}
  end

  defp parse_result({:ok, %{status: 409, body: body}}) do
    Logger.warn("Conflict. Body: #{inspect(body)}")
    {:error, {:conflict, body}}
  end

  defp parse_result({:ok, %{status: 401, body: body}}), do: {:error, {:unauthenticated, body}}

  defp parse_result({:ok, %{status: 403, body: body}}),
    do: {:error, {:unauthorized, body}}

  defp parse_result({:ok, %{status: 404}}), do: {:error, :not_found}

  defp parse_result({:ok, %{status: 503}}), do: {:error, :service_unavailable}

  defp parse_result({:ok, %{status: status, body: body}}) when is_client_error(status),
    do: {:error, {:client_error, body}}

  defp parse_result({:ok, %{status: status, body: body}}) when is_redirect(status),
    do: {:error, {:redirect_error, body}}

  defp parse_result({:ok, %{status: status, body: body}}) when is_client_error(status),
    do: {:error, {:client_error, body}}

  defp parse_result({:ok, %{status: status, body: body}}) when is_server_error(status),
    do: {:error, {:server_error, body}}

  defp parse_result({:error, _reason} = err), do: err
  defp parse_result(_), do: {:error, :unexpected_return}
end
