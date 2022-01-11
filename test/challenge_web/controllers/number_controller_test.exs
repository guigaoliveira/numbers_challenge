defmodule ChallengeWeb.NumberControllerTest do
  use ChallengeWeb.ConnCase
  alias Challenge.Cache

  alias ChallengeWeb.Router.Helpers, as: Routes

  describe "index" do
    setup [:create_numbers]

    test "lists all numbers in asc order when order_by parameter is not passed", %{
      conn: conn,
      numbers: numbers
    } do
      conn = get(conn, Routes.number_path(conn, :index))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "numbers" => Enum.sort(numbers),
                 "status" => "processed"
               }
             }
    end

    test "lists all numbers in asc order", %{conn: conn, numbers: numbers} do
      conn = get(conn, Routes.number_path(conn, :index, %{order_by: "asc"}))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "numbers" => Enum.sort(numbers),
                 "status" => "processed"
               }
             }
    end

    test "lists all numbers in desc order", %{conn: conn, numbers: numbers} do
      conn = get(conn, Routes.number_path(conn, :index, %{order_by: "desc"}))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "numbers" => Enum.sort(numbers, :desc),
                 "status" => "processed"
               }
             }
    end

    test "should returns a error when order_by is not asc or desc", %{
      conn: conn
    } do
      conn = get(conn, Routes.number_path(conn, :index, %{order_by: "option_not_exist"}))

      assert json_response(conn, 422) == %{
               "error" => "invalid params",
               "details" => [%{"order_by" => "must be \"asc\" or \"desc\""}]
             }
    end
  end

  defp create_numbers(_) do
    numbers = fixture(:numbers)
    %{numbers: numbers}
  end

  def fixture(:numbers) do
    numbers = Enum.shuffle(1..100)
    Cache.put(:extracted_numbers, numbers)
    numbers
  end
end
