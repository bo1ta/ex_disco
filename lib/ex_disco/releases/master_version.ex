defmodule ExDisco.Releases.MasterVersion do
  @moduledoc """
  A single release version returned by the master versions endpoint.

  When querying `/masters/{id}/versions`, each item in the list is a MasterVersion
  — one concrete pressing or edition of the master recording.

  ## Fields

  - `:id` — Discogs release ID for this version
  - `:title` — Title of this version
  - `:status` — Review status (e.g. "Accepted")
  - `:format` — Physical format string (e.g. "12\\\", 33 ⅓ RPM")
  - `:country` — Country of release
  - `:label` — Record label name
  - `:released` — Release year as a string (e.g. "1993")
  - `:catno` — Catalog number
  - `:major_formats` — High-level format categories (e.g. `["Vinyl"]`)
  - `:thumb` — Thumbnail image URL
  - `:resource_url` — Full API URL for this release
  - `:community_in_collection` — How many Discogs users have this in their collection
  - `:community_in_wantlist` — How many Discogs users want this
  """

  use ExDisco.Resource

  @enforce_keys [:id, :title]
  defstruct [
    :id,
    :title,
    :status,
    :format,
    :country,
    :label,
    :released,
    :catno,
    :major_formats,
    :thumb,
    :resource_url,
    :community_in_collection,
    :community_in_wantlist
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          title: String.t(),
          status: String.t() | nil,
          format: String.t() | nil,
          country: String.t() | nil,
          label: String.t() | nil,
          released: String.t() | nil,
          catno: String.t() | nil,
          major_formats: [String.t()],
          thumb: String.t() | nil,
          resource_url: String.t() | nil,
          community_in_collection: non_neg_integer() | nil,
          community_in_wantlist: non_neg_integer() | nil
        }

  @impl ExDisco.Resource
  def from_api(data) do
    community = get_in(data, ["stats", "community"]) || %{}

    %__MODULE__{
      id: data["id"],
      title: data["title"],
      status: data["status"],
      format: data["format"],
      country: data["country"],
      label: data["label"],
      released: data["released"],
      catno: data["catno"],
      major_formats: data["major_formats"] || [],
      thumb: data["thumb"],
      resource_url: data["resource_url"],
      community_in_collection: community["in_collection"],
      community_in_wantlist: community["in_wantlist"]
    }
  end
end
