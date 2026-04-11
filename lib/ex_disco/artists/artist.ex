defmodule ExDisco.Artists.Artist do
  @moduledoc """
  Discogs artist struct
  """

  alias ExDisco.Artists.ArtistAlias
  alias ExDisco.Types.Image

  @enforce_keys [:id, :name]
  defstruct [
    :id,
    :name,
    :realname,
    :profile,
    :resource_url,
    :releases_url,
    :uri,
    :thumb,
    :cover_image,
    :type,
    :data_quality,
    aliases: [],
    namevariations: [],
    image: nil
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          realname: String.t() | nil,
          profile: String.t() | nil,
          resource_url: String.t() | nil,
          releases_url: String.t() | nil,
          uri: String.t() | nil,
          thumb: String.t() | nil,
          cover_image: String.t() | nil,
          type: String.t() | nil,
          data_quality: String.t() | nil,
          aliases: [ArtistAlias.t()],
          namevariations: [String.t()],
          image: Image.t() | nil
        }

  @doc """
  Creates a new `Artist` struct from the api response.
  """
  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      realname: data["realname"],
      profile: data["profile"],
      resource_url: data["resource_url"],
      releases_url: data["releases_url"],
      uri: data["uri"],
      thumb: data["thumb"],
      cover_image: data["cover_image"],
      type: "artist",
      data_quality: data["data_quality"],
      aliases: Enum.map(data["aliases"] || [], &ArtistAlias.from_api/1),
      namevariations: data["namevariations"] || [],
      image: extract_primary_image(data["images"])
    }
  end

  @doc """
  Creates a new `Artist` struct from the search results response
  """
  @spec from_search_result(map()) :: t()
  def from_search_result(%{} = data) do
    %__MODULE__{
      id: data["id"],
      name: data["title"] || data["name"],
      profile: data["profile"],
      resource_url: data["resource_url"],
      thumb: data["thumb"],
      cover_image: data["cover_image"],
      type: data["type"] || "artist"
    }
  end

  @spec extract_primary_image([map()] | nil) :: Image.t() | nil
  defp extract_primary_image(nil), do: nil
  defp extract_primary_image([]), do: nil

  defp extract_primary_image(images) do
    case Enum.find(images, &(&1["type"] == "primary")) do
      nil -> nil
      img -> Image.from_api(img)
    end
  end
end
