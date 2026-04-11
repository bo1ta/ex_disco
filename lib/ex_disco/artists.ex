defmodule ExDisco.Artists do
  @moduledoc """
  Discogs artist resource
  """

  alias ExDisco.{API, Request, Search}
  alias ExDisco.Artists.Artist

  @doc """
  Fetches a single artist by Discogs ID
  """
  @spec get(pos_integer()) :: API.response(Artist.t())
  def get(id) when is_integer(id) and id > 0 do
    API.new_request()
    |> Request.path("/artists/#{id}")
    |> API.execute(&Artist.from_api/1)
  end

  @doc """
  Searches for artists by filters. Accepts `:name` as a convenience alias for `:q`.
  """
  @spec search(Search.filters()) :: API.response([Artist.t()])
  def search(filters) when is_list(filters) do
    case Search.query(:artist, filters) do
      {:ok, results} -> {:ok, Enum.map(results, &Artist.from_search_result/1)}
      error -> error
    end
  end
end
