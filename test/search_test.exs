defmodule ExDisco.SearchTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Search

  test "query/2 hits the search endpoint with type and filters" do
    Req.Test.expect(__MODULE__, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/database/search"

      query = URI.decode_query(conn.query_string)
      assert query["type"] == "label"
      assert query["q"] == "Fabric"

      Req.Test.json(conn, %{
        "pagination" => %{"page" => 1, "pages" => 1, "per_page" => 50, "items" => 1},
        "results" => [
          %{"id" => 1, "title" => "Fabric", "type" => "label"}
        ]
      })
    end)

    assert {:ok, [result]} = Search.query(:label, q: "Fabric")
    assert result["id"] == 1
    assert result["title"] == "Fabric"
  end

  test "query/2 injects type from atom when not provided" do
    Req.Test.expect(__MODULE__, fn conn ->
      query = URI.decode_query(conn.query_string)
      assert query["type"] == "release"

      Req.Test.json(conn, %{
        "pagination" => %{"page" => 1, "pages" => 1, "per_page" => 50, "items" => 0},
        "results" => []
      })
    end)

    assert {:ok, []} = Search.query(:release, q: "Strings of Life")
  end
end
