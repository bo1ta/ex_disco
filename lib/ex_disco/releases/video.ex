defmodule ExDisco.Releases.Video do
  @moduledoc """
  A video linked to a release (typically a YouTube URI).
  """

  @enforce_keys [:uri]
  defstruct [:uri, :title, :description, :duration, :embed]

  @type t :: %__MODULE__{
          uri: String.t(),
          title: String.t() | nil,
          description: String.t() | nil,
          duration: non_neg_integer() | nil,
          embed: boolean() | nil
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      uri: data["uri"],
      title: data["title"],
      description: data["description"],
      duration: data["duration"],
      embed: data["embed"]
    }
  end

  @spec from_api_list([map()] | nil) :: [t()]
  def from_api_list(data) when is_list(data), do: Enum.map(data, &from_api/1)
  def from_api_list(_), do: []
end
