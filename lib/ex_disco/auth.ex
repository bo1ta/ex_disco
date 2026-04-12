defmodule ExDisco.Auth do
  @moduledoc """
  Handles the Discogs OAuth 1.0a token exchange flow.

  Application-level credentials belong in config:

      config :ex_disco, ExDisco,
        consumer_key: "consumer_key",
        consumer_secret: "consumer_secret"

  Then each end user goes through the OAuth flow and you store the returned
  access credentials for that user.
  """

  alias ExDisco.API
  alias ExDisco.Auth.{OAuthCredentials, RequestToken, UserToken}
  alias ExDisco.Config

  @authorize_url "https://www.discogs.com/oauth/authorize"

  @type t :: UserToken.t() | OAuthCredentials.t() | nil

  @doc "Normalizes the credentials"
  @spec normalize(term()) :: t()
  def normalize(nil), do: nil
  def normalize(%UserToken{} = auth), do: auth
  def normalize(%OAuthCredentials{} = auth), do: auth

  def normalize(other), do: other

  @doc "Creates a new UserToken struct given a token string."
  @spec user_token(String.t()) :: UserToken.t()
  def user_token(token), do: %UserToken{token: token}

  @doc """
  Creates a new OAuthCredentials struct given the consumer_key, consumer_secret, token and token_secret
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
  """
  @spec request_token(String.t()) :: {:ok, RequestToken.t()} | {:error, ExDisco.Error.t()}
  def request_token(callback_url) when is_binary(callback_url) do
    request_token(Config.consumer_key(), Config.consumer_secret(), callback_url)
  end

  @doc """
  Requests a temporary OAuth token using explicit consumer credentials.
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
  Returns the URL to redirect the user to for authorization.
  """
  @spec authorize_url(String.t() | RequestToken.t()) :: String.t()
  def authorize_url(%RequestToken{oauth_token: oauth_token}), do: authorize_url(oauth_token)

  def authorize_url(oauth_token),
    do: @authorize_url <> "?oauth_token=" <> URI.encode_www_form(oauth_token)

  @doc """
  Exchanges a request token and verifier for long-lived OAuth credentials using
  configured consumer credentials.
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
  Exchanges a verifier for long-lived OAuth credentials using explicit
  consumer credentials.
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
