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
    :real_name,
    :profile,
    :resource_url,
    :releases_url,
    :uri,
    :thumb,
    :cover_image,
    :data_quality,
    aliases: [],
    name_variations: [],
    images: []
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          real_name: String.t() | nil,
          profile: String.t() | nil,
          resource_url: String.t() | nil,
          releases_url: String.t() | nil,
          uri: String.t() | nil,
          thumb: String.t() | nil,
          cover_image: String.t() | nil,
          data_quality: String.t() | nil,
          aliases: [ArtistAlias.t()],
          name_variations: [String.t()],
          images: list(Image.t())
        }

  @doc """
  Creates a new `Artist` struct from the api response.
  """
  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      real_name: data["realname"],
      profile: data["profile"],
      resource_url: data["resource_url"],
      releases_url: data["releases_url"],
      uri: data["uri"],
      thumb: data["thumb"],
      cover_image: data["cover_image"],
      data_quality: data["data_quality"],
      aliases: Enum.map(data["aliases"] || [], &ArtistAlias.from_api/1),
      name_variations: data["namevariations"] || [],
      images: Enum.map(data["images"] || [], &Image.from_api/1)
    }
  end
end
