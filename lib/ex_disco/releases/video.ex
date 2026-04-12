defmodule ExDisco.Releases.Video do
  @moduledoc """
  A video linked to a release (typically a YouTube URI).
  """

  use ExDisco.Resource

  @enforce_keys [:uri]
  defstruct [:uri, :title, :description, :duration, :embed]

  @type t :: %__MODULE__{
          uri: String.t(),
          title: String.t() | nil,
          description: String.t() | nil,
          duration: non_neg_integer() | nil,
          embed: boolean() | nil
        }
end
