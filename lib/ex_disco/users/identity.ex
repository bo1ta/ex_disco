defmodule ExDisco.Users.Identity do
  @moduledoc """
  Represents the authenticated user's identity as returned by `/oauth/identity`.
  """

  use ExDisco.Resource

  @enforce_keys [:id, :username, :resource_url, :consumer_name]
  defstruct [:id, :username, :resource_url, :consumer_name]

  @type t :: %__MODULE__{
          id: pos_integer(),
          username: String.t(),
          resource_url: String.t(),
          consumer_name: String.t()
        }
end
