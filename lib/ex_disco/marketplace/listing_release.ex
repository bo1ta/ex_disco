defmodule ExDisco.Marketplace.ListingRelease do
  @moduledoc """
  An abbreviated release as embedded in a Marketplace listing.
  """

  @enforce_keys [:id]
  defstruct [
    :id,
    :catalog_number,
    :resource_url,
    :year,
    :description,
    :artist,
    :title,
    :format,
    :thumbnail
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          catalog_number: String.t() | nil,
          resource_url: String.t() | nil,
          year: non_neg_integer() | nil,
          description: String.t() | nil,
          artist: String.t() | nil,
          title: String.t() | nil,
          format: String.t() | nil,
          thumbnail: String.t() | nil
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      catalog_number: data["catalog_number"],
      resource_url: data["resource_url"],
      year: data["year"],
      description: data["description"],
      artist: data["artist"],
      title: data["title"],
      format: data["format"],
      thumbnail: data["thumbnail"]
    }
  end
end
