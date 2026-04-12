defmodule ExDisco.Types.ReleaseSummary do
  @moduledoc """
  An abbreviated release as returned by artist and label release list endpoints.

  This is a summary object — it contains enough to identify and display a release,
  but not the full details (tracklist, credits, etc.) found on a full release page.
  """

  use ExDisco.Resource

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
end
