defmodule ExDisco.Config do
  @moduledoc """
  Utility that handles interaction with the application's configuration
  """

  @doc """
  Returns the configured client options.
  """
  @spec client_options() :: keyword()
  def client_options do
    Application.get_env(:ex_disco, ExDisco, [])
  end

  @doc """
  Resolves the given key from the configured client options.
  """
  @spec resolve(atom(), term()) :: term()
  def resolve(key, default \\ nil) do
    client_options()
    |> Keyword.get(key, default)
  end
end
