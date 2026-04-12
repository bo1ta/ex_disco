defmodule ExDisco.Users.Profile do
  @moduledoc """
  Represents the user profile as returned by `/users/{username}`
  """

  use ExDisco.Resource

  @enforce_keys [:id, :username, :resource_url, :uri]
  defstruct [
    :id,
    :email,
    :profile,
    :wantlist_url,
    :rank,
    :num_pending,
    :num_for_sale,
    :home_page,
    :location,
    :collection_folders_url,
    :username,
    :collection_fields_url,
    :releases_contributed,
    :registered,
    :rating_avg,
    :num_collection,
    :releases_rated,
    :num_lists,
    :name,
    :num_wantlist,
    :inventory_url,
    :avatar_url,
    :banner_url,
    :uri,
    :resource_url,
    :buyer_rating,
    :buyer_rating_stars,
    :buyer_num_ratings,
    :seller_rating,
    :seller_rating_stars,
    :seller_num_ratings,
    :curr_abbr
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          email: String.t() | nil,
          profile: String.t(),
          wantlist_url: String.t(),
          rank: pos_integer(),
          num_pending: pos_integer(),
          num_for_sale: pos_integer(),
          home_page: String.t() | nil,
          location: String.t(),
          collection_folders_url: String.t(),
          username: String.t(),
          collection_fields_url: String.t(),
          releases_contributed: pos_integer(),
          registered: DateTime.t(),
          rating_avg: float(),
          num_collection: pos_integer(),
          releases_rated: pos_integer(),
          num_lists: pos_integer(),
          name: String.t(),
          num_wantlist: pos_integer(),
          inventory_url: String.t(),
          avatar_url: String.t(),
          banner_url: String.t(),
          uri: String.t(),
          resource_url: String.t(),
          buyer_rating: float(),
          buyer_rating_stars: pos_integer(),
          buyer_num_ratings: pos_integer(),
          seller_rating: float(),
          seller_rating_stars: pos_integer(),
          seller_num_ratings: pos_integer(),
          curr_abbr: String.t()
        }
end
