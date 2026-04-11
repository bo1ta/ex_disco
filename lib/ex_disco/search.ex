defmodule ExDisco.Search do
  @moduledoc """
  Generic Discogs search across resource types.
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
  Searches the Discogs database for a given resource type.

  Returns a list of raw result maps. Callers are responsible for mapping
  results into typed structs.

  ## Examples

      ExDisco.Search.query(:artist, q: "Rhadoo")
      ExDisco.Search.query(:label, q: "Fabric")

  """
  @spec query(query_type(), filters()) :: {:ok, [map()]} | {:error, Error.t()}
  def query(type, filters) when is_atom(type) and is_list(filters) do
    params = Keyword.put_new(filters, :type, Atom.to_string(type))

    Request.new()
    |> Request.path("/database/search")
    |> Request.put_query(params)
    |> Request.execute_collection(& &1)
  end
end
