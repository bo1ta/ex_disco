defmodule ExDisco.SearchTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Page
  alias ExDisco.Search

  test "query/2 hits the search endpoint with type and filters" do
    stub_response(
      fixture("search"),
      fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/database/search"

        query = URI.decode_query(conn.query_string)
        assert query["type"] == "label"
        assert query["q"] == "Fabric"
      end
    )

    assert {:ok, %Page{} = page} = Search.query(type: :label, q: "Fabric")
    assert page.page == 1
    assert page.pages == 66
    assert page.per_page == 3
    assert page.total == 198
    assert [result, _, _] = page.items
    assert result["id"] == 2_028_757
    assert result["title"] == "Nirvana - Nevermind"
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

    assert {:ok, %Page{items: [], page: 1, pages: 1, per_page: 50, total: 0}} =
             Search.query(q: "Strings of Life", type: :release)
  end
end
