defmodule ExDisco.Auth.Authorization do
  @moduledoc """
  The single public-facing authentication type for the Discogs API.

  Use the factory functions to create an `Authorization` and pass it as the
  first argument to any function that requires authentication.

  ## Personal Token

      token = ExDisco.Config.user_token()
      auth = ExDisco.Auth.Authorization.for_user_token(token)

      auth
      |> ExDisco.Users.get_identity()

  ## OAuth

      {:ok, credentials} = ExDisco.Auth.access_token(request_token, verifier)

      credentials
      |> ExDisco.Users.get_identity()
  """

  alias ExDisco.Auth.Authorization

  defstruct [:type, :credentials]

  @type t :: %__MODULE__{
          type: :user_token | :oauth,
          credentials: term()
        }

  @doc """
  Creates an `Authorization` from a personal token string.

  ## Examples

      iex> ExDisco.Auth.Authorization.for_user_token("my_token")
      %ExDisco.Auth.Authorization{type: :user_token, credentials: "my_token"}
  """
  @spec for_user_token(String.t()) :: t()
  def for_user_token(token) when is_binary(token) do
    %Authorization{type: :user_token, credentials: token}
  end

  @doc """
  Creates an `Authorization` from OAuth credentials.

  ## Examples

      iex> ExDisco.Auth.Authorization.for_oauth("key", "secret", "token", "token_secret")
      %ExDisco.Auth.Authorization{type: :oauth, credentials: %{...}}
  """
  @spec for_oauth(String.t(), String.t(), String.t(), String.t()) :: t()
  def for_oauth(consumer_key, consumer_secret, token, token_secret) do
    %Authorization{
      type: :oauth,
      credentials: %{
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        token: token,
        token_secret: token_secret
      }
    }
  end

  @doc false
  @spec to_header(t() | nil, atom(), String.t(), keyword()) ::
          {String.t(), String.t()} | nil
  def to_header(%Authorization{type: :user_token, credentials: token}, _method, _url, _query) do
    {"authorization", "Discogs token=#{token}"}
  end

  def to_header(
        %Authorization{
          type: :oauth,
          credentials: %{
            consumer_key: consumer_key,
            consumer_secret: consumer_secret,
            token: token,
            token_secret: token_secret
          }
        },
        method,
        url,
        query
      ) do
    credentials =
      OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        token: token,
        token_secret: token_secret
      )

    signed = OAuther.sign(method |> to_string() |> String.upcase(), url, query, credentials)
    {{header_key, header_value}, _params} = OAuther.header(signed)
    {header_key, header_value}
  end

  def to_header(nil, _method, _url, _query), do: nil
end
