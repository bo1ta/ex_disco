defmodule ExDisco.Types.ArtistCredit do
  @moduledoc """
  An artist appearance on a release with role and formatting information.

  Artist credits represent how an artist appears on a specific release, including
  their role (vocals, guitar, producer, etc.), the name variation used (ANV), and
  how their name is formatted relative to other credits (join phrase).

  ## Fields

  - `:id` — Artist's unique Discogs ID
  - `:name` — Artist's primary name
  - `:anv` — Alternate name variation (ANV) as it appears on this release
  - `:role` — Artist's role (e.g., "Vocals", "Guitar", "Producer", "Mixing")
  - `:join` — Joining phrase (e.g., " featuring ", " & ", " vs. ")
  - `:tracks` — Specific tracks this credit applies to (if partial credit)
  - `:resource_url` — Discogs API URL for this artist

  ## Examples

  Access artist credits on a release:

      {:ok, release} = ExDisco.Releases.get(249504)

  The join phrase is used to format display:

      "Artist A" <> credit.join <> "Artist B"
      # "Artist A featuring Artist B"
  """

  use ExDisco.Resource

  @enforce_keys [:id, :name]
  defstruct [:id, :name, :anv, :role, :join, :tracks, :resource_url]

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          anv: String.t() | nil,
          role: String.t() | nil,
          join: String.t() | nil,
          tracks: String.t() | nil,
          resource_url: String.t() | nil
        }

  @impl ExDisco.Resource
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      anv: data["anv"],
      role: data["role"],
      join: data["join"],
      tracks: data["tracks"],
      resource_url: data["resource_url"]
    }
  end
end
