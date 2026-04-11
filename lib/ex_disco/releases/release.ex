defmodule ExDisco.Releases.Release do
  @moduledoc """
  Full Discogs release object.
  """

  alias ExDisco.Releases.{Community, Format, Track, Video}
  alias ExDisco.Types.{ArtistCredit, CreditEntity, Image}

  @enforce_keys [:id, :title]
  defstruct [
    :id,
    :title,
    :status,
    :country,
    :notes,
    :released,
    :released_formatted,
    :resource_url,
    :uri,
    :thumb,
    :master_id,
    :master_url,
    :data_quality,
    :lowest_price,
    :num_for_sale,
    :estimated_weight,
    :format_quantity,
    :year,
    :date_added,
    :date_changed,
    :community,
    artists: [],
    extraartists: [],
    companies: [],
    formats: [],
    genres: [],
    identifiers: [],
    images: [],
    labels: [],
    series: [],
    styles: [],
    tracklist: [],
    videos: []
  ]

  @type release_identifier :: %{type: String.t(), value: String.t()}

  @type t :: %__MODULE__{
          id: pos_integer(),
          title: String.t(),
          status: String.t() | nil,
          country: String.t() | nil,
          notes: String.t() | nil,
          released: String.t() | nil,
          released_formatted: String.t() | nil,
          resource_url: String.t() | nil,
          uri: String.t() | nil,
          thumb: String.t() | nil,
          master_id: pos_integer() | nil,
          master_url: String.t() | nil,
          data_quality: String.t() | nil,
          lowest_price: float() | nil,
          num_for_sale: non_neg_integer() | nil,
          estimated_weight: non_neg_integer() | nil,
          format_quantity: non_neg_integer() | nil,
          year: non_neg_integer() | nil,
          date_added: String.t() | nil,
          date_changed: String.t() | nil,
          community: Community.t() | nil,
          artists: [ArtistCredit.t()],
          extraartists: [ArtistCredit.t()],
          companies: [CreditEntity.t()],
          formats: [Format.t()],
          genres: [String.t()],
          identifiers: [release_identifier()],
          images: [Image.t()],
          labels: [CreditEntity.t()],
          series: [String.t()],
          styles: [String.t()],
          tracklist: [Track.t()],
          videos: [Video.t()]
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      title: data["title"],
      status: data["status"],
      country: data["country"],
      notes: data["notes"],
      released: data["released"],
      released_formatted: data["released_formatted"],
      resource_url: data["resource_url"],
      uri: data["uri"],
      thumb: data["thumb"],
      master_id: data["master_id"],
      master_url: data["master_url"],
      data_quality: data["data_quality"],
      lowest_price: data["lowest_price"],
      num_for_sale: data["num_for_sale"],
      estimated_weight: data["estimated_weight"],
      format_quantity: data["format_quantity"],
      year: data["year"],
      date_added: data["date_added"],
      date_changed: data["date_changed"],
      community: Community.from_api(data["community"]),
      artists: ArtistCredit.from_api_list(data["artists"]),
      extraartists: ArtistCredit.from_api_list(data["extraartists"]),
      companies: CreditEntity.from_api_list(data["companies"]),
      formats: Format.from_api_list(data["formats"]),
      genres: data["genres"] || [],
      identifiers: parse_identifiers(data["identifiers"]),
      images: Image.from_api_list(data["images"]),
      labels: CreditEntity.from_api_list(data["labels"]),
      series: data["series"] || [],
      styles: data["styles"] || [],
      tracklist: Track.from_api_list(data["tracklist"]),
      videos: Video.from_api_list(data["videos"])
    }
  end

  @spec parse_identifiers([map()] | nil) :: [release_identifier()]
  defp parse_identifiers(nil), do: []

  defp parse_identifiers(identifiers) do
    Enum.map(identifiers, fn %{"type" => type, "value" => value} ->
      %{type: type, value: value}
    end)
  end
end
