defmodule ExDisco.Marketplace.Listing do
  @moduledoc """
  A Marketplace listing, as returned by the inventory and listing endpoints.

  Fields `shipping_price`, `original_price`, `original_shipping_price`, and `in_cart`
  are only present on the single-listing endpoint or when authenticated as the listing owner.
  """

  alias ExDisco.Marketplace.{ListingRelease, ListingSeller, Price}

  @enforce_keys [:id, :status]
  defstruct [
    :id,
    :status,
    :condition,
    :sleeve_condition,
    :price,
    :original_price,
    :allow_offers,
    :posted,
    :ships_from,
    :uri,
    :comments,
    :seller,
    :release,
    :resource_url,
    :audio,
    :shipping_price,
    :original_shipping_price,
    :in_cart
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          status: String.t(),
          condition: String.t() | nil,
          sleeve_condition: String.t() | nil,
          price: Price.t() | nil,
          original_price: map() | nil,
          allow_offers: boolean() | nil,
          posted: String.t() | nil,
          ships_from: String.t() | nil,
          uri: String.t() | nil,
          comments: String.t() | nil,
          seller: ListingSeller.t() | nil,
          release: ListingRelease.t() | nil,
          resource_url: String.t() | nil,
          audio: boolean() | nil,
          shipping_price: Price.t() | nil,
          original_shipping_price: map() | nil,
          in_cart: boolean() | nil
        }

  @spec from_api(map()) :: t()
  def from_api(data) do
    %__MODULE__{
      id: data["id"],
      status: data["status"],
      condition: data["condition"],
      sleeve_condition: data["sleeve_condition"],
      price: Price.from_api(data["price"]),
      original_price: data["original_price"],
      allow_offers: data["allow_offers"],
      posted: data["posted"],
      ships_from: data["ships_from"],
      uri: data["uri"],
      comments: data["comments"],
      seller: ListingSeller.from_api(data["seller"]),
      release: ListingRelease.from_api(data["release"]),
      resource_url: data["resource_url"],
      audio: data["audio"],
      shipping_price: Price.from_api(data["shipping_price"]),
      original_shipping_price: data["original_shipping_price"],
      in_cart: data["in_cart"]
    }
  end
end
