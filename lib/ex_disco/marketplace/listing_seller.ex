defmodule ExDisco.Marketplace.ListingSeller do
  @moduledoc """
  Seller information as embedded in a Marketplace listing.
  """

  @enforce_keys [:id, :username]
  defstruct [
    :id,
    :username,
    :resource_url,
    :avatar_url,
    :url,
    :shipping,
    :payment,
    :stats
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          username: String.t(),
          resource_url: String.t() | nil,
          avatar_url: String.t() | nil,
          url: String.t() | nil,
          shipping: String.t() | nil,
          payment: String.t() | nil,
          stats: map() | nil
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      username: data["username"],
      resource_url: data["resource_url"],
      avatar_url: data["avatar_url"],
      url: data["url"],
      shipping: data["shipping"],
      payment: data["payment"],
      stats: data["stats"]
    }
  end
end
