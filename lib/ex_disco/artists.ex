defmodule ExDisco.Artists do
  @moduledoc """
  Discogs artist resource
  """

  alias ExDisco.{Request, Search, Error}
  alias ExDisco.Artists.Artist
  alias ExDisco.Types.ReleaseSummary

  @doc "Fetches a single artist by Discogs ID."
  @spec get(pos_integer()) :: {:ok, Artist.t()} | {:error, Error.t()}
  def get(id) when is_integer(id) and id > 0 do
    Request.get("/artists/#{id}")
    |> Request.execute(&Artist.from_api/1)
  end

  @doc "Fetches a paginated list of releases for a given artist ID."
  @spec get_releases(pos_integer()) :: {:ok, [ReleaseSummary.t()]} | {:error, Error.t()}
  def get_releases(id) when is_integer(id) and id > 0 do
    Request.get("/artists/#{id}/releases")
    |> Request.execute_collection("releases", &ReleaseSummary.from_api/1)
  end

  @doc "Searches for artists by filters and maps the results."
  @spec search(Search.filters()) :: {:ok, [Artist.t()]} | {:error, Error.t()}
  def search(filters) when is_list(filters) do
    with {:ok, results} <- Search.query(:artist, filters) do
      {:ok, Enum.map(results, &Artist.from_search_result/1)}
    end
  end
end
