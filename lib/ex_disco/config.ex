defmodule ExDisco.Config do
  @moduledoc """
  Utility that handles interaction with the application's configuration and provides it.
  """

  alias ExDisco.Auth

  @base_url "https://api.discogs.com"
  @default_user_agent "ex_disco/0.1.0"

  @doc "Returns the Discogs API base url"
  def base_url, do: @base_url

  @doc "Returns the Discogs API base url with the given path"
  @spec base_url(binary()) :: String.t()
  def base_url(path), do: @base_url <> path

  @doc "Returns the resolved User Agent, either from Application config or default"
  def user_agent, do: resolve(:user_agent, @default_user_agent)

  @doc "Returns the configured OAuth consumer key."
  def consumer_key, do: resolve(:consumer_key)

  @doc "Returns the configured OAuth consumer secret."
  def consumer_secret, do: resolve(:consumer_secret)

  @doc "Returns the resolved Auth."
  def auth, do: resolve(:auth) |> Auth.normalize()

  @doc "Returns extra Req options, mainly for tests."
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
