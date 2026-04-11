defmodule ExDisco.Releases.Rating do
  @moduledoc """
  The average rating and the total number of user ratings for a given release.
  """

  @enforce_keys [:count, :average]
  defstruct [:count, :average]

  @type t :: %__MODULE__{count: pos_integer(), average: float()}

  @spec from_api(map()) :: t()
  def from_api(data) do
    rating = data["rating"]

    %__MODULE__{
      count: rating["count"],
      average: rating["average"]
    }
  end
end
