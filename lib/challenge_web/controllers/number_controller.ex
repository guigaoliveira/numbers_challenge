defmodule ChallengeWeb.NumberController do
  use ChallengeWeb, :controller

  alias Challenge.Numbers

  @doc """
  List all sorted numbers
  """
  @spec index(Plug.Conn.t(), nil | maybe_improper_list | map) :: Plug.Conn.t()
  def index(conn, %{"order_by" => order_by})
      when is_binary(order_by) and order_by in ["asc", "desc"],
      do: process_index(conn, %{order_by: order_by})

  def index(conn, %{"order_by" => _}) do
    conn
    |> put_status(422)
    |> json(%{
      error: "invalid params",
      details: [%{order_by: "must be \"asc\" or \"desc\""}]
    })
  end

  def index(conn, _params), do: process_index(conn, %{order_by: nil})

  defp process_index(conn, params) do
    data =
      case Numbers.all(params) do
        nil ->
          %{status: "unprocessed", numbers: []}

        numbers ->
          %{status: "processed", numbers: numbers}
      end

    json(conn, %{data: data})
  end
end
