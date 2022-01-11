defmodule WorkerTest do
  use ExUnit.Case

  alias Challenge.{Cache, Worker}

  doctest Worker

  @moduletag :integration

  test "should extract numbers from external api and add to cache" do
    Cache.delete_all()

    assert %{attempt: 0, data: [_ | _], status: :ok} = Worker.perform(1..1)
    assert Cache.get(:extracted_numbers) != []
  end

  test "should retry perform/" do
    Cache.delete_all()

    max_retries = 3

    Application.put_env(:challenge, Worker,
      max_retries: max_retries,
      retry_delay: 0,
      delay_request: 1
    )

    assert Worker.perform("not range") == %{attempt: max_retries, data: [], status: :ignore}
    assert Cache.get(:extracted_numbers) != []
  end
end
