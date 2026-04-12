defmodule ExDisco.Labels.Label do
  @moduledoc """
  A record label (publisher) from Discogs.

  Labels represent record companies, publishers, or other entities that release
  music. They can range from major corporations to independent publishers and
  can have sublabels.

  ## Fields

  - `:id` — Unique Discogs label ID
  - `:name` — Label name
  - `:profile` — Label description and history
  - `:contact_info` — Contact information (phone, email, etc.)
  - `:urls` — Official website and social media URLs
  - `:images` — Label logo and other images
  - `:releases_url` — API endpoint for this label's releases
  - `:data_quality` — Discogs data quality rating

  ## Examples

  Fetch label information:

      {:ok, label} = ExDisco.Labels.get(1)
      IO.inspect(label.name)
      IO.inspect(label.profile)

  Get releases from a label:

      {:ok, releases} = ExDisco.Labels.get_releases(1)
      Enum.each(releases, &IO.inspect(&1.title))

  See `ExDisco.Types.Image` for image field details.
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
