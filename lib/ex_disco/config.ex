defmodule ExDisco.Config do
  @moduledoc """
  Application configuration for ExDisco.

  This module reads configuration from your application's config.exs file.
  All configuration is optional except for a user-agent.

  ## Configuration Options

  ```elixir
  config :ex_disco, ExDisco,
    user_agent: "my_app/1.0.0 (+https://github.com/me/my_app)",  # Required
    user_token: "your_token",                                     # For personal auth
    consumer_key: "your_key",                                     # For OAuth
    consumer_secret: "your_secret",                               # For OAuth
    req_options: [timeout: 10000]                                 # Optional Req config
  ```

  You only need to configure authentication for features you use:
  - Personal use: Set `user_token`
  - Multi-user OAuth: Set `consumer_key` and `consumer_secret`

  The Discogs API requires a user-agent identifying your application.
  This is mandatory.

  ## Examples

  In your config.exs:

      config :ex_disco, ExDisco,
        user_agent: "my_app/1.0.0 (+https://github.com/example/my_app)",
        user_token: System.fetch_env!("DISCOGS_TOKEN")

  Then use the configuration in your application:

      token = ExDisco.Config.auth()
      # token is an ExDisco.Auth.UserToken or nil
  """

  alias ExDisco.Auth

  @base_url "https://api.discogs.com"
  @default_user_agent "ex_disco/0.1.0"

  @doc """
  Returns the base URL for the Discogs API.

  ## Examples

      iex> ExDisco.Config.base_url()
      "https://api.discogs.com"
  """
  def base_url, do: @base_url

  @doc """
  Returns the base URL with the given path appended.

  ## Examples

      iex> ExDisco.Config.base_url("/artists/1")
      "https://api.discogs.com/artists/1"
  """
  @spec base_url(binary()) :: String.t()
  def base_url(path), do: @base_url <> path

  @doc """
  Returns the configured user-agent string.

  Uses the value from config.exs if set, otherwise returns a default.

  ## Examples

      iex> ExDisco.Config.user_agent()
      "my_app/1.0.0 (+https://github.com/me/my_app)"
  """
  def user_agent, do: resolve(:user_agent, @default_user_agent)

  @doc """
  Returns the configured OAuth consumer key, or nil if not configured.

  ## Examples

      iex> ExDisco.Config.consumer_key()
      "your_consumer_key"
  """
  def consumer_key, do: resolve(:consumer_key)

  @doc """
  Returns the configured OAuth consumer secret, or nil if not configured.

  ## Examples

      iex> ExDisco.Config.consumer_secret()
      "your_consumer_secret"
  """
  def consumer_secret, do: resolve(:consumer_secret)

  @doc """
  Returns the configured authentication, or nil if not configured.

  If a personal token is configured, returns a UserToken. Otherwise returns nil.

  ## Examples

      iex> ExDisco.Config.auth()
      %ExDisco.Auth.UserToken{token: "..."}

      iex> ExDisco.Config.auth()
      nil
  """
  def auth do
    case resolve(:user_token) do
      nil -> nil
      token -> Auth.user_token(token)
    end
  end

  @doc """
  Returns extra options for the Req HTTP client, or an empty list.

  Mainly used for testing and debugging. Allows per-request Req customization
  like timeouts, proxies, or additional headers.

  ## Examples

      iex> ExDisco.Config.req_options()
      [timeout: 10000]
  """
  def req_options, do: resolve(:req_options, [])

  @doc """
  Resolves the given key from the configured client options.
  """
  @spec resolve(atom(), term()) :: term()
  def resolve(key, default \\ nil) do
    Application.get_env(:ex_disco, ExDisco, [])
    |> Keyword.get(key, default)
  end
end
