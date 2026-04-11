defmodule ExDisco.Types.Image do
  @moduledoc """
  Discogs artist image struct
  """

  @enforce_keys [:uri]
  defstruct [:uri, :uri150, :resource_url, :type, :width, :height]

  @type t :: %__MODULE__{
          uri: String.t(),
          uri150: String.t() | nil,
          resource_url: String.t() | nil,
          type: String.t() | nil,
          width: pos_integer() | nil,
          height: pos_integer() | nil
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      uri: data["uri"],
      uri150: data["uri150"],
      resource_url: data["resource_url"],
      type: data["type"],
      width: data["width"],
      height: data["height"]
    }
  end

  @spec from_api_list(list(map())) :: [t()]
  def from_api_list(data) when is_list(data), do: Enum.map(data, &from_api/1)

  def from_api_list(_), do: []
end
