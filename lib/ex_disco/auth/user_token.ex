defmodule ExDisco.Auth.UserToken do
  @moduledoc """
  Simple Discogs user token authentication.
  """

  @enforce_keys [:token]
  defstruct [:token]

  @type t :: %__MODULE__{
          token: String.t()
        }
end
