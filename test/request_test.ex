defmodule do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Request

  test "request builder can override app-configured auth per request" do
    Application.put_env(:ex_disco, ExDisco,
      user_agent: "ex_disco/0.1.0",
      auth: %UserToken{token: "global-token"},
      req_options: [plug: {Req.Test, __MODULE__}]
    )

    Req.Test.expect(__MODULE__, fn conn ->
      assert {"authorization", "Discogs token=request-token"} in conn.req_headers
      refute {"authorization", "Discogs token=global-token"} in conn.req_headers
      Req.Test.json(conn, %{"id" => 1})
    end)

    assert {:ok, %{"id" => 1}} =
             Request.new()
             |> Request.path("/artists/1")
             |> Request.put_auth(Auth.user_token("request-token"))
             |> Request.execute(& &1)
  end
end
