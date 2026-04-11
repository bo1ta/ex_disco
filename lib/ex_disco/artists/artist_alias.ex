defmodule ExDisco.Artists.ArtistAlias do
  @moduledoc """
  Discogs artist alias struct
  """

  @enforce_keys [:id, :name]
  defstruct [:id, :name, :resource_url]

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          resource_url: String.t() | nil
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      resource_url: data["resource_url"]
    }
  end
end
