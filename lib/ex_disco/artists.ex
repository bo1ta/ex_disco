defmodule ExDisco.Artists do
  @moduledoc """
  Discogs artist resource
  """

  alias ExDisco.{API, Request, Search, Error}
  alias ExDisco.Artists.Artist

  @doc """
  Fetches a single artist by Discogs ID
  """
  @spec get(pos_integer()) :: {:ok, Artist.t()} | {:error, Error.t()}
  def get(id) when is_integer(id) and id > 0 do
    API.new_request()
    |> Request.path("/artists/#{id}")
    |> API.execute(&Artist.from_api/1)
  end

  @doc """
  Searches for artists by filters.
  """
  @spec search(Search.filters()) :: {:ok, [Artist.t()]} | {:error, Error.t()}
  def search(filters) when is_list(filters) do
    with {:ok, results} <- Search.query(:artist, filters) do
      {:ok, Enum.map(results, &Artist.from_search_result/1)}
    end
  end
end
