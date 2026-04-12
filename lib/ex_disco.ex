defmodule ExDisco do
  @moduledoc """
  Elixir client for the Discogs API.

  Discogs is the world's largest crowdsourced music database. ExDisco provides
  a type-safe, ergonomic Elixir interface to query artists, releases, labels,
  and users, with support for both personal token and OAuth 1.0a authentication.

  ## Getting Started

  Start by configuring a user-agent (required by Discogs):

      config :ex_disco, ExDisco,
        user_agent: "my_app/1.0.0 (+https://github.com/me/my_app)"

  Then fetch data:

      {:ok, artist} = ExDisco.Artists.get(1)
      IO.inspect(artist.name)

  See the resource modules for specific data types:
  - `ExDisco.Artists` — Query artists
  - `ExDisco.Releases` — Query releases (albums, EPs, etc.)
  - `ExDisco.Labels` — Query record labels
  - `ExDisco.Users` — Query user profiles
  - `ExDisco.Search` — Global search

  ## Configuration

  ### Required: User Agent

  Discogs requires all applications identify themselves with a user agent:

      config :ex_disco, ExDisco,
        user_agent: "my_app/1.0.0 (+https://github.com/me/my_app)"

  ### Optional: Authentication

  Choose one of two approaches:

  #### Personal Token (Simple)

  For personal scripts, CLIs, and single-user applications. Get a token at
  https://www.discogs.com/settings/developers, then configure it:

      config :ex_disco, ExDisco,
        user_token: "your_token"

  Use it in requests:

      token = ExDisco.Auth.user_token("your_token")
      Request.get("/users/me")
      |> Request.put_auth(token)
      |> Request.execute(&User.Identity.from_api/1)

  #### OAuth 1.0a (Multi-User)

  For applications acting on behalf of multiple users. Register your app at
  https://www.discogs.com/settings/developers to obtain consumer credentials:

      config :ex_disco, ExDisco,
        consumer_key: "your_consumer_key",
        consumer_secret: "your_consumer_secret"

  Each user goes through the OAuth flow to obtain their own access token and
  secret. Store these per-user and pass them to authenticated requests:

      credentials = ExDisco.Auth.oauth_credentials(
        consumer_key,
        consumer_secret,
        user.discogs_token,
        user.discogs_token_secret
      )

      Request.get("/users/me")
      |> Request.put_auth(credentials)
      |> Request.execute(&User.Identity.from_api/1)

  See `ExDisco.Auth` for the complete OAuth flow documentation.

  ## Examples

  Fetch an artist:

      {:ok, artist} = ExDisco.Artists.get(1)

  Fetch release information:

      {:ok, release} = ExDisco.Releases.get(249504)

  Search the database:

      {:ok, results} = ExDisco.Search.query([q: "Thriller", type: :release])

  Handle errors:

      case ExDisco.Artists.get(9999999) do
        {:ok, artist} -> IO.inspect(artist)
        {:error, error} -> IO.inspect("Error: \#{error.message}")
      end

  See the request builder for advanced usage:

      {:ok, releases} = ExDisco.Request.get("/artists/1/releases")
      |> ExDisco.Request.put_query(per_page: 25)
      |> ExDisco.Request.execute_collection("releases", &ReleaseSummary.from_api/1)
  """
end
