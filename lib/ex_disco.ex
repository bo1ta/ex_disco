defmodule ExDisco do
  @moduledoc """
  Elixir client for the Discogs API.

  ## Configuration

  ### User Agent

  Discogs asks that you identify your application:

      config :ex_disco, ExDisco,
        user_agent: "my_app/1.0.0 (+https://github.com/me/my_app)"

  ### Authentication

  #### Personal token

  The simplest option — acts only as you. Suitable for personal scripts and CLIs.
  Generate one at https://www.discogs.com/settings/developers

      config :ex_disco, ExDisco,
        user_token: "your_token"

  #### OAuth 1.0a

  Required when your app acts on behalf of other users. Register your app at
  https://www.discogs.com/settings/developers to obtain a consumer key and secret,
  then configure them at the app level:

      config :ex_disco, ExDisco,
        consumer_key: "your_consumer_key",
        consumer_secret: "your_consumer_secret"

  Each user goes through the OAuth flow via `ExDisco.Auth` to obtain their own
  access token and secret. These are per-user credentials and should be stored in
  your database — not in config. Pass them at call time via `Request.put_auth/2`
  when building requests that require user-level authorization:

      credentials = ExDisco.Auth.oauth_credentials(
        consumer_key,
        consumer_secret,
        user.discogs_token,
        user.discogs_token_secret
      )

      Request.get("/users/\#{username}/collection")
      |> Request.put_auth(credentials)
      |> Request.execute(&Collection.from_api/1)

  See `ExDisco.Auth` for the full OAuth flow.
  """
end
