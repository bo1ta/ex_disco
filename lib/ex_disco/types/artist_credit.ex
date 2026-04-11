defmodule ExDisco.Types.ArtistCredit do
  @moduledoc """
  An artist credit as it appears on a release — carries the role, join phrase,
  and any name variation (ANV) used on that specific release.
  """

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

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      anv: presence(data["anv"]),
      role: presence(data["role"]),
      join: presence(data["join"]),
      tracks: presence(data["tracks"]),
      resource_url: data["resource_url"]
    }
  end

  @spec from_api_list([map()] | nil) :: [t()]
  def from_api_list(data) when is_list(data), do: Enum.map(data, &from_api/1)
  def from_api_list(_), do: []

  defp presence(""), do: nil
  defp presence(value), do: value
end
