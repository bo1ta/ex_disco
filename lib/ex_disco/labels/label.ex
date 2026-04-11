defmodule ExDisco.Labels.Label do
  @moduledoc """
  Discogs Label struct
  """

  alias ExDisco.Types.Image

  @enforce_keys [:id, :name]
  defstruct [
    :id,
    :profile,
    :releases_url,
    :name,
    :contact_info,
    :uri,
    :urls,
    :images,
    :resource_url,
    :data_quality
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          profile: String.t(),
          resource_url: String.t(),
          releases_url: String.t(),
          uri: String.t(),
          images: [Image.t()],
          contact_info: String.t() | nil,
          urls: [String.t()],
          data_quality: String.t()
        }

  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      profile: data["profile"],
      resource_url: data["resource_url"],
      releases_url: data["releases_url"] || [],
      uri: data["uri"],
      images: Image.from_api_list(data["images"]),
      contact_info: data["contact_info"],
      urls: data["urls"] || [],
      data_quality: data["data_quality"]
    }
  end
end
