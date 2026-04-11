defmodule ExDisco.Releases.Format do
  @moduledoc """
  A physical or digital format of a release (e.g. Vinyl 7\", CD, Digital Media).
  """

  @enforce_keys [:name]
  defstruct [:name, :qty, descriptions: []]

  @type t :: %__MODULE__{
          name: String.t(),
          qty: String.t() | nil,
          descriptions: [String.t()]
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      name: data["name"],
      qty: data["qty"],
      descriptions: data["descriptions"] || []
    }
  end

  @spec from_api_list([map()] | nil) :: [t()]
  def from_api_list(data) when is_list(data), do: Enum.map(data, &from_api/1)
  def from_api_list(_), do: []
end
