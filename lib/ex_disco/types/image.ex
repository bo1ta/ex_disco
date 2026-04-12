defmodule ExDisco.Types.Image do
  @moduledoc """
  A Discogs image — covers both full-size and thumbnail URIs.
  """

  use ExDisco.Resource

  @enforce_keys [:uri]
  defstruct [:uri, :uri150, :resource_url, :type, :width, :height]

  @type t :: %__MODULE__{
          uri: String.t(),
          uri150: String.t() | nil,
          resource_url: String.t() | nil,
          type: String.t() | nil,
          width: pos_integer() | nil,
          height: pos_integer() | nil
        }
end
