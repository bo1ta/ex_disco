defmodule ExDisco.Types.CreditEntity do
  @moduledoc """
  A label or company credit on a release.

  Used for both the `labels` and `companies` lists on a full release —
  they share the same shape, with `entity_type_name` present only on companies.
  """

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

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      catno: presence(data["catno"]),
      entity_type: data["entity_type"],
      entity_type_name: data["entity_type_name"],
      resource_url: data["resource_url"]
    }
  end

  @spec from_api_list([map()] | nil) :: [t()]
  def from_api_list(data) when is_list(data), do: Enum.map(data, &from_api/1)
  def from_api_list(_), do: []

  defp presence(""), do: nil
  defp presence(value), do: value
end
