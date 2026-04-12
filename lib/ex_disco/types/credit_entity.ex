defmodule ExDisco.Types.CreditEntity do
  @moduledoc """
  A label or company credit on a release.

  Used for both the `labels` and `companies` lists on a full release —
  they share the same shape, with `entity_type_name` present only on companies.
  """

  use ExDisco.Resource

  @enforce_keys [:id, :name]
  defstruct [:id, :name, :catno, :entity_type, :entity_type_name, :resource_url]

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          catno: String.t() | nil,
          entity_type: String.t() | nil,
          entity_type_name: String.t() | nil,
          resource_url: String.t() | nil
        }

  @impl ExDisco.Resource
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      catno: data["catno"],
      entity_type: data["entity_type"],
      entity_type_name: data["entity_type_name"],
      resource_url: data["resource_url"]
    }
  end
end
