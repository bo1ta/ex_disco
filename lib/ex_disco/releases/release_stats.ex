defmodule ExDisco.Releases.ReleaseStats do
  @moduledoc """
  Community stats for a release — how many users have it and want it.
  """

  use ExDisco.Resource

  @enforce_keys [:is_offensive]
  defstruct [:num_have, :num_want, :is_offensive]

  @type t :: %__MODULE__{
          num_have: pos_integer() | nil,
          num_want: pos_integer() | nil,
          is_offensive: boolean()
        }
end
