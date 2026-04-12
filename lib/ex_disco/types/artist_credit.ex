defmodule ExDisco.Types.ArtistCredit do
  @moduledoc """
  An artist credit as it appears on a release — carries the role, join phrase,
  and any name variation (ANV) used on that specific release.
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
