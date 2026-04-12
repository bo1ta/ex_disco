defmodule ExDisco.Releases.UserRating do
  @moduledoc """
  The Release's Rating for a given user
  """

  use ExDisco.Resource

  @enforce_keys [:release_id, :rating, :username]
  defstruct [:release_id, :rating, :username]

  @type t :: %__MODULE__{
          release_id: pos_integer(),
          rating: pos_integer(),
          username: String.t()
        }
end
