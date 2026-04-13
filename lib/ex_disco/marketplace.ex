defmodule ExDisco.Marketplace do
  @moduledoc """
  Query marketplace information from Discogs.
  """

  alias ExDisco.{Error, Page, Request}
  alias ExDisco.Auth.Authorization
  alias ExDisco.Marketplace.{Listing, NewListing}

  import ExDisco.Guards, only: [is_non_empty_binary: 1, is_positive_integer: 1]

  @doc """
  Returns the list of listings in a user's inventory. Accepts pagination parameters.

  Basic information about each listing and the corresponding release is provided,
  suitable for display in a list. For detailed information about the release, fetch
  the corresponding Release separately.

  If not authenticated as the inventory owner, only items with status `For Sale` are
  visible. When authenticated as the owner, additional fields are included.

  ## Options

  - `:status` — Only show items with this status (e.g. `"for sale"`)
  - `:sort` — Sort field: `listed`, `price`, `item`, `artist`, `label`, `catno`, `audio`, `status`, `location`
  - `:sort_order` — `asc` or `desc`
  - `:page` — Page number
  - `:per_page` — Items per page
  """
  @spec get_inventory(String.t(), keyword()) :: {:ok, Page.t(Listing.t())} | {:error, Error.t()}
  def get_inventory(username, opts \\ [])

  def get_inventory(username, opts) when is_non_empty_binary(username) and is_list(opts) do
    Request.get(["users", username, "inventory"])
    |> Request.put_query(opts)
    |> Request.execute_page("listings", &Listing.from_api/1)
  end

  def get_inventory(_, _), do: Error.invalid_argument("username must be a non-empty string")

  @doc """
  View the data associated with a listing.

  If authenticated as the listing owner, additional fields are included.

  ## Options

  - `:curr_abbr` — Currency for price data (e.g. `"USD"`). Defaults to the authenticated user's currency.
    Must be one of: `USD GBP EUR CAD AUD JPY CHF MXN BRL NZD SEK ZAR`
  """
  @spec get_listing(pos_integer(), keyword()) :: {:ok, Listing.t()} | {:error, Error.t()}
  def get_listing(listing_id, opts \\ [])

  def get_listing(listing_id, opts) when is_positive_integer(listing_id) and is_list(opts) do
    Request.get("/marketplace/listings/#{listing_id}")
    |> Request.put_query(opts)
    |> Request.execute(&Listing.from_api/1)
  end

  def get_listing(_, _), do: Error.invalid_argument("listing_id must be a positive integer")

  @doc """
  Create a Marketplace listing.

  Authentication is required; the listing will be added to the authenticated user's inventory.

  ## Parameters

  - `:release_id` (required) — The ID of the release being listed
  - `:condition` (required) — Condition of the item (e.g. `"Mint (M)"`)
  - `:price` (required) — Price in the seller's currency
  - `:status` (required) — `"For Sale"` or `"Draft"`
  - `:sleeve_condition` (optional) — Condition of the sleeve
  - `:comments` (optional) — Remarks displayed to buyers
  - `:allow_offers` (optional) — Whether to allow buyer offers (default: `false`)
  - `:external_id` (optional) — Private seller reference ("Private Comments")
  - `:location` (optional) — Physical storage location (private)
  - `:weight` (optional) — Weight in grams, or `"auto"`
  - `:format_quantity` (optional) — Counts-as quantity for shipping, or `"auto"`
  """
  @spec create_listing(Authorization.t(), map()) :: {:ok, NewListing.t()} | {:error, Error.t()}
  def create_listing(%Authorization{} = auth, params) when is_map(params) do
    Request.post("/marketplace/listings")
    |> Request.put_auth(auth)
    |> Request.put_body(params)
    |> Request.execute(&NewListing.from_api/1)
  end

  def create_listing(nil, _), do: Error.auth_required()
  def create_listing(_, _), do: Error.invalid_argument("params must be a map")

  @doc """
  Edit the data associated with a listing.

  Authentication as the listing owner is required. Only listings with status
  `For Sale`, `Draft`, or `Expired` can be modified.

  Accepts the same parameters as `create_listing/2`.
  """
  @spec update_listing(Authorization.t(), pos_integer(), map()) :: :ok | {:error, Error.t()}
  def update_listing(auth, listing_id, params)

  def update_listing(%Authorization{} = auth, listing_id, params)
      when is_positive_integer(listing_id) and is_map(params) do
    with {:ok, _} <-
           Request.put("/marketplace/listings/#{listing_id}")
           |> Request.put_auth(auth)
           |> Request.put_body(params)
           |> Request.execute() do
      :ok
    end
  end

  def update_listing(nil, _, _), do: Error.auth_required()

  def update_listing(_, listing_id, _) when not is_positive_integer(listing_id),
    do: Error.invalid_argument("listing_id must be a positive integer")

  def update_listing(_, _, _), do: Error.invalid_argument("params must be a map")

  @doc """
  Permanently remove a listing from the Marketplace.

  Authentication as the listing owner is required.
  """
  @spec delete_listing(Authorization.t(), pos_integer()) :: :ok | {:error, Error.t()}
  def delete_listing(%Authorization{} = auth, listing_id) when is_positive_integer(listing_id) do
    with {:ok, _} <-
           Request.delete("/marketplace/listings/#{listing_id}")
           |> Request.put_auth(auth)
           |> Request.execute() do
      :ok
    end
  end

  def delete_listing(nil, _), do: Error.auth_required()

  def delete_listing(_, _),
    do: Error.invalid_argument("listing_id must be a positive integer")
end
