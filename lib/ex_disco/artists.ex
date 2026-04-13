defmodule ExDisco.Artists do
  @moduledoc """
  Query artist information from Discogs.

  Artists represent individual musicians, groups, or collectives that have
  released music. Each artist has a unique Discogs ID and can have releases,
  aliases (alternate names), and related metadata.

  ## Examples

  Fetch an artist by ID:

      {:ok, artist} = ExDisco.Artists.get(1)
      IO.inspect(artist.name)

  Fetch releases by an artist:

      {:ok, releases} = ExDisco.Artists.get_releases(1)
      Enum.each(releases, &IO.inspect(&1.title))

  See `ExDisco.Artists.Artist` for the artist data structure.
  """

  alias ExDisco.{Error, Page, Request}
  alias ExDisco.Artists.Artist
  alias ExDisco.Types.ReleaseSummary

  @doc """
  Fetch a single artist by Discogs ID.

  Returns detailed information about the artist including name, profile,
  images, aliases, and discography links.

  ## Examples

      iex> ExDisco.Artists.get(1)
      {:ok, %ExDisco.Artists.Artist{id: 1, name: "Arif Mardin", ...}}

      iex> ExDisco.Artists.get(9999999)
      {:error, %ExDisco.Error{type: :not_found}}
  """
  @spec get(pos_integer()) :: {:ok, Artist.t()} | {:error, Error.t()}
  def get(id) when is_integer(id) and id > 0 do
    Request.get("/artists/#{id}")
    |> Request.execute(&Artist.from_api/1)
  end

  def get(_), do: Error.invalid_argument("id must be a positive integer")

  @doc """
  Fetch releases (albums, EPs, singles) by an artist.

  Returns a paginated list of the artist's releases. Use the `opts` keyword list
  to control pagination and sorting.

  ## Options

  - `:page` — Page number (default: 1)
  - `:per_page` — Items per page (default: 50)
  - `:sort` — Sort field: `year`, `title`, `format`
  - `:sort_order` — `asc` or `desc`

  ## Examples

      iex> ExDisco.Artists.get_releases(1)
      {:ok, %ExDisco.Page{items: [%ExDisco.Types.ReleaseSummary{}, ...], total: 42}}

      iex> ExDisco.Artists.get_releases(1, page: 2, per_page: 25, sort: "year")
      {:ok, %ExDisco.Page{items: [...], page: 2, pages: 3}}
  """
  @spec get_releases(pos_integer(), keyword()) ::
          {:ok, Page.t(ReleaseSummary.t())} | {:error, Error.t()}
  def get_releases(id, opts \\ [])

  def get_releases(id, opts) when is_integer(id) and id > 0 and is_list(opts) do
    Request.get("/artists/#{id}/releases")
    |> Request.put_query(opts)
    |> Request.execute_page("releases", &ReleaseSummary.from_api/1)
  end

  def get_releases(_, _), do: Error.invalid_argument("id must be a positive integer")
end
