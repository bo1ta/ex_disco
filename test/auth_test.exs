defmodule ExDisco.AuthTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Auth
  alias ExDisco.Auth.{OAuthCredentials, RequestToken, UserToken}

  test "normalizes legacy auth tuples into structs" do
    assert %UserToken{token: "abc"} = Auth.normalize({:user_token, "abc"})

    assert %OAuthCredentials{
             consumer_key: "ck",
             consumer_secret: "cs",
             token: "token",
             token_secret: "secret"
           } = Auth.normalize({:oauth, "ck", "cs", "token", "secret"})
  end

  test "request_token/1 returns a stable request token struct" do
    Application.put_env(:ex_disco, ExDisco,
      user_agent: "ex_disco/0.1.0",
      consumer_key: "ck",
      consumer_secret: "cs",
      req_options: [plug: {Req.Test, __MODULE__}]
    )

    Req.Test.expect(__MODULE__, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/oauth/request_token"
      assert {"user-agent", "ex_disco/0.1.0"} in conn.req_headers

      Plug.Conn.send_resp(
        conn,
        200,
        "oauth_token=req-token&oauth_token_secret=req-secret&oauth_callback_confirmed=true"
      )
    end)

    assert {:ok,
            %RequestToken{
              oauth_token: "req-token",
              oauth_token_secret: "req-secret",
              oauth_callback_confirmed: "true"
            }} = Auth.request_token("https://example.com/callback")
  end
end
