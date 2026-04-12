defmodule ExDisco.ApiCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  @fixtures_path Path.expand("fixtures", __DIR__)

  using options do
    quote do
      use ExUnit.Case, unquote(options)
      import ExDisco.ApiCase, only: [configure_ex_disco: 1, fixture: 1]

      setup {Req.Test, :set_req_test_from_context}
      setup {Req.Test, :verify_on_exit!}
      setup :configure_ex_disco

      # Stubs a successful JSON response. Uses Req.Test under the hood,
      # so it consumes one expected request (just like Req.Test.expect/2 would).
      #
      #     stub_response(fixture("identity_get"))
      #
      defp stub_response(body) do
        Req.Test.expect(__MODULE__, fn conn ->
          conn
          |> Plug.Conn.put_status(200)
          |> Req.Test.json(body)
        end)
      end

      defp stub_response(body, status) when is_integer(status) do
        Req.Test.expect(__MODULE__, fn conn ->
          conn
          |> Plug.Conn.put_status(status)
          |> Req.Test.json(body)
        end)
      end

      # Pass a 1-arity callback to run assertions on the conn before responding:
      #
      #     stub_response(fixture("identity_get"), fn conn ->
      #       assert conn.method == "GET"
      #       assert conn.request_path == "/oauth/identity"
      #       assert {"authorization", "Discogs token=abc"} in conn.req_headers
      #     end)
      #
      defp stub_response(body, callback) when is_function(callback, 1) do
        Req.Test.expect(__MODULE__, fn conn ->
          callback.(conn)

          conn
          |> Plug.Conn.put_status(200)
          |> Req.Test.json(body)
        end)
      end

      # Stubs an error response using the shared error_response fixture.
      # Pass the HTTP status code you want to simulate.
      #
      #     stub_error(401)  # → %Error{type: :unauthorized, message: "You must authenticate..."}
      #     stub_error(404)  # → %Error{type: :not_found, ...}
      #
      defp stub_error(status) do
        stub_response(ExDisco.ApiCase.fixture("error_response"), status)
      end

      # Returns a %UserToken{} for use in authenticated calls.
      # The default token is "test-token" — override when the specific value matters.
      #
      #     Users.get_identity(user_token())
      #     Users.get_identity(user_token("real-personal-token"))
      #
      defp user_token(token \\ "test-token") do
        ExDisco.Auth.user_token(token)
      end

      # Returns an %OAuthCredentials{} for use in per-user OAuth calls.
      # Defaults to predictable test values — override only when the specific values matter.
      #
      #     Users.get_identity(oauth_credentials())
      #     Users.get_identity(oauth_credentials("ck", "cs", "tok", "sec"))
      #
      defp oauth_credentials(
             consumer_key \\ "test-consumer-key",
             consumer_secret \\ "test-consumer-secret",
             token \\ "test-token",
             token_secret \\ "test-token-secret"
           ) do
        ExDisco.Auth.oauth_credentials(consumer_key, consumer_secret, token, token_secret)
      end
    end
  end

  def configure_ex_disco(%{module: module}) do
    Application.put_env(:ex_disco, ExDisco,
      user_agent: "ex_disco/0.1.0",
      req_options: [plug: {Req.Test, module}]
    )

    on_exit(fn -> Application.delete_env(:ex_disco, ExDisco) end)

    :ok
  end

  @doc """
  Loads and JSON-decodes a fixture file from `test/support/fixtures/`.

      fixture("releases_get")  # reads test/support/fixtures/releases_get.json
  """
  def fixture(name) do
    @fixtures_path
    |> Path.join("#{name}.json")
    |> File.read!()
    |> Jason.decode!()
  end
end
