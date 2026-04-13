defmodule ExDisco.Marketplace.NewListing do
  @moduledoc """
  The response returned after successfully creating a Marketplace listing.
  """

  @enforce_keys [:listing_id, :resource_url]
  defstruct [:listing_id, :resource_url]

  @type t :: %__MODULE__{
          listing_id: pos_integer(),
          resource_url: String.t()
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      listing_id: data["listing_id"],
      resource_url: data["resource_url"]
    }
  end
end
