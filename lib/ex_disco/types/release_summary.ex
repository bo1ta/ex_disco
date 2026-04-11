defmodule ExDisco.Types.ReleaseSummary do
  @moduledoc """
  An abbreviated release as returned by artist and label release list endpoints.

  This is a summary object — it contains enough to identify and display a release,
  but not the full details (tracklist, credits, etc.) found on a full release page.
  """

  @enforce_keys [:id, :title]
  defstruct [
    :id,
    :title,
    :artist,
    :type,
    :role,
    :status,
    :format,
    :label,
    :catno,
    :year,
    :thumb,
    :resource_url,
    :main_release
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          title: String.t(),
          artist: String.t() | nil,
          type: String.t() | nil,
          role: String.t() | nil,
          status: String.t() | nil,
          format: String.t() | nil,
          label: String.t() | nil,
          catno: String.t() | nil,
          year: non_neg_integer() | nil,
          thumb: String.t() | nil,
          resource_url: String.t() | nil,
          main_release: pos_integer() | nil
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      title: data["title"],
      artist: data["artist"],
      type: data["type"],
      role: data["role"],
      status: data["status"],
      format: data["format"],
      label: data["label"],
      catno: data["catno"],
      year: data["year"],
      thumb: data["thumb"],
      resource_url: data["resource_url"],
      main_release: data["main_release"]
    }
  end
end
