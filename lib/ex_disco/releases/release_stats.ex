defmodule ExDisco.Releases.ReleaseStats do
  @moduledoc """
  Discogs Release Stats struct
  """

  @enforce_keys [:is_offensive]
  defstruct [:num_have, :num_want, :is_offensive]

  @type t :: %__MODULE__{
          num_have: pos_integer() | nil,
          num_want: pos_integer() | nil,
          is_offensive: boolean()
        }

  @doc """
  Creates a new `ReleaseStats` struct from the api response.
  """
  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      num_have: data["num_have"],
      num_want: data["num_want"],
      is_offensive: data["is_offensive"]
    }
  end
end
