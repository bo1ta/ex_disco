defmodule ExDisco.Search do
  @moduledoc """
  Global search across the entire Discogs database.

  The search API allows you to search for artists, releases, masters, and labels
  using various filters. Results are returned as raw maps that you can map to
  typed structs if needed.

  ## Search Types

  - `:artist` — Search for artists
  - `:release` — Search for releases (specific versions)
  - `:master` — Search for masters (abstract works)
  - `:label` — Search for record labels

  ## Common Filters

  - `:q` — General text search
  - `:title` — Search by title/name
  - `:artist` — Search by artist name
  - `:label` — Search by record label
  - `:year` — Filter by release year
  - `:genre` — Filter by genre
  - `:format` — Filter by format (Vinyl, CD, etc.)
  - `:per_page` — Results per page (default: 50)
  - `:page` — Page number

  ## Examples

  Search for an artist:

      {:ok, results} = ExDisco.Search.query([type: :artist, q: "Rhadoo"])
      Enum.each(results, &IO.inspect(&1["title"]))

  Search releases with filters:

      {:ok, results} = ExDisco.Search.query([
        type: :release,
        title: "Thriller",
        artist: "Michael Jackson",
        year: 1982
      ])
  """

  alias ExDisco.{Request, Error}

  @type query_type :: :release | :master | :artist | :label

  @type filter_key ::
          :q
          | :title
          | :artist
          | :label
          | :album
          | :catno
          | :type
          | :barcode
          | :format
          | :year
          | :genre
          | :style
          | :track
          | :contributor
          | :sort
          | :sort_order
          | :page
          | :per_page

  @type filters :: [{filter_key(), String.t() | integer()}]

  @doc """
  Search the Discogs database with filters.

  Searches across the database using various filter parameters. Returns raw
  result maps (not typed structs). You can map results to structs if needed.

  The `:type` filter is usually required to specify what you're searching for.

  ## Examples

      iex> ExDisco.Search.query([type: :artist, q: "Rhadoo"])
      {:ok, [%{"id" => 123, "title" => "Rhadoo", ...}, ...]}

      iex> ExDisco.Search.query([type: :release, title: "Thriller", year: 1982])
      {:ok, [%{"id" => 456, "title" => "Thriller", ...}, ...]}

      iex> ExDisco.Search.query([type: :label, q: "Defected"])
      {:ok, [%{"id" => 789, "title" => "Defected", ...}, ...]}
  """
  @spec query(filters()) :: {:ok, [map()]} | {:error, Error.t()}
  def query(filters) when is_list(filters) do
    params =
      filters
      |> Keyword.update(:type, nil, &if(is_atom(&1), do: Atom.to_string(&1), else: &1))

    Request.get("/database/search")
    |> Request.put_query(params)
    |> Request.execute_collection(& &1)
  end
end
