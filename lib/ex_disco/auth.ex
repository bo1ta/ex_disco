defmodule ExDisco.Auth do
  @moduledoc """
  Authentication and authorization for the Discogs API.

  ## Authentication Methods

  ExDisco supports two authentication approaches:

  ### Personal Token (Simple)

  For personal use and single-user applications, use a personal token from
  https://www.discogs.com/settings/developers. Pass it per-request:

      token = ExDisco.Auth.user_token("your_token")
      Request.get("/users/me")
      |> Request.put_auth(token)
      |> Request.execute(...)

  ### OAuth 1.0a (Multi-User)

  For applications acting on behalf of multiple users, implement the full OAuth flow.

  #### Step 1: Get Consumer Credentials

  Register your application at https://www.discogs.com/settings/developers to obtain
  consumer_key and consumer_secret. Store these in your config:

      config :ex_disco, ExDisco,
        consumer_key: "your_consumer_key",
        consumer_secret: "your_consumer_secret"

  #### Step 2: Request a Temporary Token

  When a user logs in, request a temporary token that directs them to Discogs:

      {:ok, request_token} = ExDisco.Auth.request_token("https://yourapp.com/callback")

  Store the request_token temporarily (it's short-lived).

  #### Step 3: Redirect User to Authorization

  Direct the user to Discogs with:

      url = ExDisco.Auth.authorize_url(request_token)
      # Redirect user to this URL

  Discogs returns them to your callback URL with an oauth_verifier parameter.

  #### Step 4: Exchange for Long-Lived Credentials

  Use the verifier to get permanent credentials:

      {:ok, credentials} = ExDisco.Auth.access_token(request_token, verifier)

  Store these credentials (consumer_key, consumer_secret, token, token_secret) for the user.

  #### Step 5: Make Authenticated Requests

  Use the stored credentials for future requests:

      credentials = ExDisco.Auth.oauth_credentials(
        consumer_key, consumer_secret, token, token_secret
      )
      Request.get("/users/me")
      |> Request.put_auth(credentials)
      |> Request.execute(...)

  ## Examples

  Get an artist with a personal token:

      token = ExDisco.Auth.user_token("your_token")
      {:ok, artist} = Request.get("/artists/1")
        |> Request.put_auth(token)
        |> Request.execute(&Artist.from_api/1)

  Start OAuth flow:

      {:ok, req_token} = ExDisco.Auth.request_token("https://yourapp.com/auth/callback")
      url = ExDisco.Auth.authorize_url(req_token)
      # Redirect user to url
      # After user approves, Discogs redirects to callback with oauth_verifier

  Complete OAuth:

      {:ok, credentials} = ExDisco.Auth.access_token(req_token, oauth_verifier)
      # Store credentials.token and credentials.token_secret for the user
  """

  alias ExDisco.API
  alias ExDisco.Auth.{OAuthCredentials, RequestToken, UserToken}
  alias ExDisco.Config

  @authorize_url "https://www.discogs.com/oauth/authorize"

  @type t :: UserToken.t() | OAuthCredentials.t() | nil

  @doc """
  Normalizes authentication credentials to a standard format.

  Accepts UserToken, OAuthCredentials, or nil. Returns the credential
  as-is if already in the correct format, or nil if passed nil.

  ## Examples

      iex> ExDisco.Auth.normalize(%ExDisco.Auth.UserToken{token: "abc"})
      %ExDisco.Auth.UserToken{token: "abc"}

      iex> ExDisco.Auth.normalize(nil)
      nil
  """
  @spec normalize(term()) :: t()
  def normalize(nil), do: nil
  def normalize(%UserToken{} = auth), do: auth
  def normalize(%OAuthCredentials{} = auth), do: auth

  def normalize(other), do: other

  @doc """
  Creates a UserToken for personal token authentication.

  Simple wrapper for a personal token obtained from
  https://www.discogs.com/settings/developers.

  ## Examples

      iex> token = ExDisco.Auth.user_token("my_token_abc123")
      iex> token.token
      "my_token_abc123"
  """
  @spec user_token(String.t()) :: UserToken.t()
  def user_token(token), do: %UserToken{token: token}

  @doc """
  Creates an OAuthCredentials struct from OAuth credentials.

  Use this after completing the OAuth 1.0a flow to wrap the obtained
  credentials for authenticated requests.

  ## Examples

      iex> creds = ExDisco.Auth.oauth_credentials("key", "secret", "token", "token_secret")
      iex> creds.token
      "token"
  """
  @spec oauth_credentials(String.t(), String.t(), String.t(), String.t()) :: OAuthCredentials.t()
  def oauth_credentials(consumer_key, consumer_secret, token, token_secret) do
    %OAuthCredentials{
      consumer_key: consumer_key,
      consumer_secret: consumer_secret,
      token: token,
      token_secret: token_secret
    }
  end

  @doc """
  Requests a temporary OAuth token using configured consumer credentials.

  The callback_url is where Discogs will redirect the user after they authorize
  your app. This is Step 1 of the OAuth flow.

  ## Examples

      iex> ExDisco.Auth.request_token("https://myapp.com/auth/callback")
      {:ok, %ExDisco.Auth.RequestToken{...}}
  """
  @spec request_token(String.t()) :: {:ok, RequestToken.t()} | {:error, ExDisco.Error.t()}
  def request_token(callback_url) when is_binary(callback_url) do
    request_token(Config.consumer_key(), Config.consumer_secret(), callback_url)
  end

  @doc """
  Requests a temporary OAuth token using explicit consumer credentials.

  Use this if your consumer credentials are not in config. Same as request_token/1
  but accepts credentials directly instead of reading from config.

  ## Examples

      iex> ExDisco.Auth.request_token("key", "secret", "https://myapp.com/auth/callback")
      {:ok, %ExDisco.Auth.RequestToken{...}}
  """
  @spec request_token(String.t(), String.t(), String.t()) ::
          {:ok, RequestToken.t()} | {:error, ExDisco.Error.t()}
  def request_token(consumer_key, consumer_secret, callback_url) do
    url = Config.base_url("/oauth/request_token")

    credentials =
      OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret
      )

    signed = OAuther.sign("GET", url, [{"oauth_callback", callback_url}], credentials)

    url
    |> auth_request(:get, [oauth_header(signed)], [], nil)
    |> normalize_auth_response(&parse_request_token/1)
  end

  @doc """
  Generates the URL to redirect the user to for authorization.

  This is Step 2 of the OAuth flow. Redirect the user to this URL so they can
  approve your app. After approval, Discogs redirects them back to your callback
  URL with an oauth_verifier parameter.

  Can accept either a RequestToken struct or a raw oauth_token string.

  ## Examples

      iex> token = %ExDisco.Auth.RequestToken{oauth_token: "temp_token"}
      iex> url = ExDisco.Auth.authorize_url(token)
      iex> String.starts_with?(url, "https://www.discogs.com/oauth/authorize")
      true

      iex> url = ExDisco.Auth.authorize_url("temp_token")
      iex> String.contains?(url, "oauth_token=temp_token")
      true
  """
  @spec authorize_url(String.t() | RequestToken.t()) :: String.t()
  def authorize_url(%RequestToken{oauth_token: oauth_token}), do: authorize_url(oauth_token)

  def authorize_url(oauth_token),
    do: @authorize_url <> "?oauth_token=" <> URI.encode_www_form(oauth_token)

  @doc """
  Exchanges a verifier for permanent OAuth credentials using configured credentials.

  This is Step 4 of the OAuth flow. After the user approves your app on Discogs
  and is redirected back to your callback URL, you'll receive an oauth_verifier.
  Use this function to exchange it for long-lived credentials.

  Store the returned credentials (token and token_secret) for the user so you can
  make authenticated requests on their behalf.

  ## Examples

      iex> req_token = %ExDisco.Auth.RequestToken{oauth_token: "...", oauth_token_secret: "..."}
      iex> ExDisco.Auth.access_token(req_token, "verifier_from_discogs")
      {:ok, %ExDisco.Auth.OAuthCredentials{...}}
  """
  @spec access_token(RequestToken.t(), String.t()) ::
          {:ok, OAuthCredentials.t()} | {:error, ExDisco.Error.t()}
  def access_token(%RequestToken{} = request_token, verifier) when is_binary(verifier) do
    access_token(
      Config.consumer_key(),
      Config.consumer_secret(),
      request_token.oauth_token,
      request_token.oauth_token_secret,
      verifier
    )
  end

  @doc """
  Exchanges a verifier for permanent OAuth credentials using explicit credentials.

  Same as access_token/2 but accepts credentials directly instead of reading
  from config. Use when your consumer credentials are not in config.

  ## Examples

      iex> ExDisco.Auth.access_token("key", "secret", "req_token", "req_secret", "verifier")
      {:ok, %ExDisco.Auth.OAuthCredentials{...}}
  """
  @spec access_token(String.t(), String.t(), String.t(), String.t(), String.t()) ::
          {:ok, OAuthCredentials.t()} | {:error, ExDisco.Error.t()}
  def access_token(consumer_key, consumer_secret, oauth_token, oauth_token_secret, verifier) do
    url = Config.base_url("/oauth/access_token")

    credentials =
      OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        token: oauth_token,
        token_secret: oauth_token_secret
      )

    signed = OAuther.sign("POST", url, [{"oauth_verifier", verifier}], credentials)

    url
    |> auth_request(:post, [oauth_header(signed)], [], nil)
    |> normalize_auth_response(&parse_access_token(&1, consumer_key, consumer_secret))
  end

  defp auth_request(url, method, headers, query, body) do
    Req.new(
      Keyword.merge(
        Config.req_options(),
        method: method,
        url: url,
        headers: [{"user-agent", Config.user_agent()} | headers],
        params: query,
        body: body
      )
    )
    |> Req.request()
  rescue
    exception in [Req.TransportError] ->
      {:error, exception}
  end

  defp normalize_auth_response({:ok, %{status: status, body: body}}, mapper)
       when status in 200..299 do
    {:ok, mapper.(body)}
  end

  defp normalize_auth_response({:ok, %{status: status, body: body}}, _mapper) do
    {:error, API.api_error(status, body)}
  end

  defp normalize_auth_response({:error, reason}, _mapper) do
    {:error, API.transport_error(reason)}
  end

  defp parse_request_token(body) do
    params = parse_token_response(body)

    %RequestToken{
      oauth_token: params["oauth_token"],
      oauth_token_secret: params["oauth_token_secret"],
      oauth_callback_confirmed: params["oauth_callback_confirmed"]
    }
  end

  defp parse_access_token(body, consumer_key, consumer_secret) do
    params = parse_token_response(body)

    %OAuthCredentials{
      consumer_key: consumer_key,
      consumer_secret: consumer_secret,
      token: params["oauth_token"],
      token_secret: params["oauth_token_secret"]
    }
  end

  defp parse_token_response(body) when is_binary(body), do: URI.decode_query(body)

  defp parse_token_response(body) when is_map(body) do
    Map.new(body, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      pair -> pair
    end)
  end

  defp parse_token_response(body), do: body

  defp oauth_header(signed) do
    {{header_key, header_value}, _params} = OAuther.header(signed)

    {header_key, header_value}
  end
end
