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
  Searches the Discogs database for a given resource type.

  Returns a list of raw result maps. Callers are responsible for mapping
  results into typed structs.

  ## Examples

      ExDisco.Search.query(type: :artist, q: "Rhadoo")
      ExDisco.Search.query(type: :label, q: "Fabric")

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
