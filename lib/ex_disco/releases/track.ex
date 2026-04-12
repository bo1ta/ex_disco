defmodule ExDisco.Releases.Track do
  @moduledoc """
  A single entry in a release tracklist.
  """

  use ExDisco.Resource

  @enforce_keys [:title]
  defstruct [:title, :position, :duration, :type]

  @type t :: %__MODULE__{
          title: String.t(),
          position: String.t() | nil,
          duration: String.t() | nil,
          type: String.t() | nil
        }

  @impl ExDisco.Resource
  def from_api(data) do
    %__MODULE__{
      title: data["title"],
      position: data["position"],
      duration: data["duration"],
      type: data["type_"]
    }
  end
end
