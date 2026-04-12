defmodule ExDisco.Releases.Format do
  @moduledoc """
  A physical or digital format of a release (e.g. Vinyl 7\", CD, Digital Media).
  """

  use ExDisco.Resource

  @enforce_keys [:name]
  defstruct [:name, :qty, descriptions: []]

  @type t :: %__MODULE__{
          name: String.t(),
          qty: String.t() | nil,
          descriptions: [String.t()]
        }

  @impl ExDisco.Resource
  def from_api(data) do
    %__MODULE__{
      name: data["name"],
      qty: data["qty"],
      descriptions: data["descriptions"] || []
    }
  end
end
