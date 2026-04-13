defmodule ExDisco.Releases.MasterRelease do
  @moduledoc """
  The Master resource represents a set of similar Releases.

  Masters (also known as “master releases”) have a “main release” which is often the chronologically earliest.
  """

  use ExDisco.Resource

  alias ExDisco.Releases.{Video, Track}
  alias ExDisco.Types.{ArtistCredit, Image}

  @enforce_keys [:id, :main_release]
  defstruct [
    :id,
    :title,
    :main_release,
    :main_release_url,
    :num_for_sale,
    :lowest_price,
    :data_quality,
    :genres,
    :videos,
    :uri,
    :artists,
    :versions_url,
    :year,
    :images,
    :resource_url,
    :tracklist,
    :styles
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          title: String.t(),
          main_release: String.t(),
          main_release_url: String.t(),
          num_for_sale: pos_integer(),
          lowest_price: float(),
          data_quality: String.t(),
          styles: [String.t()],
          genres: [String.t()],
          videos: [Video.t()],
          uri: String.t(),
          artists: [ArtistCredit.t()],
          versions_url: String.t(),
          year: pos_integer(),
          images: [Image.t()],
          resource_url: String.t(),
          tracklist: [Track.t()]
        }

  @impl ExDisco.Resource
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      title: data["title"],
      main_release: data["main_release"],
      main_release_url: data["main_release_url"],
      num_for_sale: data["num_for_sale"],
      lowest_price: data["lowest_price"],
      data_quality: data["data_quality"],
      styles: data["styles"],
      genres: data["genres"],
      uri: data["uri"],
      resource_url: data["resource_url"],
      year: data["year"],
      versions_url: data["versions_url"],
      videos: Video.from_api_list(data["videos"]),
      artists: ArtistCredit.from_api_list(data["artists"]),
      images: Image.from_api_list(data["images"]),
      tracklist: Track.from_api_list(data["tracklist"])
    }
  end
end
