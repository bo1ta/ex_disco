defmodule ExDisco.Artists.ArtistAlias do
  @moduledoc """
  Discogs artist alias struct
  """

  use ExDisco.Resource

  @enforce_keys [:id, :name]
  defstruct [:id, :name, :resource_url]

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          resource_url: String.t() | nil
        }
end
