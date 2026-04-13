defmodule ExDisco.RequestTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Auth.Authorization
  alias ExDisco.Request

  test "get/1 builds a path from segments and encodes dynamic values" do
    Req.Test.expect(__MODULE__, fn conn ->
      assert conn.request_path == "/users/space%20cadet%2F%231"
      Req.Test.json(conn, %{"id" => 1})
    end)

    assert {:ok, %{"id" => 1}} =
             Request.get(["users", "space cadet/#1"])
             |> Request.execute(& &1)
  end

  test "put/1 builds a path from mixed string and integer segments" do
    Req.Test.expect(__MODULE__, fn conn ->
      assert conn.request_path == "/releases/249504/rating/space%20cadet%2F%231"
      Req.Test.json(conn, %{"rating" => 5})
    end)

    assert {:ok, %{"rating" => 5}} =
             Request.put(["releases", 249_504, "rating", "space cadet/#1"])
             |> Request.put_body(%{rating: 5})
             |> Request.execute(& &1)
  end

  test "put_auth sets the authorization header on the request" do
    Req.Test.expect(__MODULE__, fn conn ->
      assert {"authorization", "Discogs token=my-token"} in conn.req_headers
      Req.Test.json(conn, %{"id" => 1})
    end)

    assert {:ok, %{"id" => 1}} =
             Request.get("/artists/1")
             |> Request.put_auth(Authorization.for_user_token("my-token"))
             |> Request.execute(& &1)
  end

  test "no auth header when auth is nil" do
    Req.Test.expect(__MODULE__, fn conn ->
      refute Enum.any?(conn.req_headers, fn {k, _} -> k == "authorization" end)
      Req.Test.json(conn, %{"id" => 1})
    end)

    assert {:ok, %{"id" => 1}} =
             Request.get("/artists/1")
             |> Request.execute(& &1)
  end
end
