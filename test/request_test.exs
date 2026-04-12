defmodule ExDisco.RequestTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Auth.Authorization
  alias ExDisco.Request

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
