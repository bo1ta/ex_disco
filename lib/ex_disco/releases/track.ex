defmodule ExDisco.Releases.Track do
  @moduledoc """
  A single entry in a release tracklist.
  """

  @enforce_keys [:title]
  defstruct [:title, :position, :duration, :type]

  @type t :: %__MODULE__{
          title: String.t(),
          position: String.t() | nil,
          duration: String.t() | nil,
          type: String.t() | nil
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      title: data["title"],
      position: data["position"],
      duration: presence(data["duration"]),
      type: data["type_"]
    }
  end

  @spec from_api_list([map()] | nil) :: [t()]
  def from_api_list(data) when is_list(data), do: Enum.map(data, &from_api/1)
  def from_api_list(_), do: []

  defp presence(""), do: nil
  defp presence(value), do: value
end
