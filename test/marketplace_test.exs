defmodule ExDisco.MarketplaceTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.{Error, Marketplace, Page}
  alias ExDisco.Marketplace.{Listing, ListingRelease, ListingSeller, NewListing, Price}

  describe "get_inventory/1,2" do
    test "returns a Page of listings" do
      stub_response(fixture("inventory"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/users/360vinyl/inventory"
      end)

      assert {:ok, %Page{items: items}} = Marketplace.get_inventory("360vinyl")
      assert length(items) == 2
      assert Enum.all?(items, &match?(%Listing{}, &1))
    end

    test "maps listing scalar fields" do
      stub_response(fixture("inventory"))

      assert {:ok, %Page{items: [listing | _]}} = Marketplace.get_inventory("360vinyl")
      assert listing.id == 150_899_904
      assert listing.status == "For Sale"
      assert listing.condition == "Near Mint (NM or M-)"
      assert listing.sleeve_condition == "Near Mint (NM or M-)"
      assert listing.allow_offers == true
      assert listing.posted == "2014-07-01T10:20:17-07:00"
      assert listing.ships_from == "United States"
      assert listing.uri == "https://www.discogs.com/sell/item/150899904"
      assert listing.comments == "Includes promotional booklet from original purchase!"
      assert listing.resource_url == "https://api.discogs.com/marketplace/listings/150899904"
      assert listing.audio == false
    end

    test "maps listing price" do
      stub_response(fixture("inventory"))

      assert {:ok, %Page{items: [listing | _]}} = Marketplace.get_inventory("360vinyl")
      assert %Price{currency: "USD", value: 149.99} = listing.price
    end

    test "maps listing seller" do
      stub_response(fixture("inventory"))

      assert {:ok, %Page{items: [listing | _]}} = Marketplace.get_inventory("360vinyl")

      assert %ListingSeller{
               id: 2_098_225,
               username: "rappcats",
               resource_url: "https://api.discogs.com/users/rappcats"
             } = listing.seller
    end

    test "maps listing release" do
      stub_response(fixture("inventory"))

      assert {:ok, %Page{items: [listing | _]}} = Marketplace.get_inventory("360vinyl")

      assert %ListingRelease{
               id: 2_992_668,
               catalog_number: "TMR092",
               year: 2011,
               artist: "Danger Mouse & Daniele Luppi",
               title: "Rome"
             } = listing.release
    end

    test "maps pagination metadata" do
      stub_response(fixture("inventory"))

      assert {:ok, %Page{page: 1, pages: 1, per_page: 50, total: 2}} =
               Marketplace.get_inventory("360vinyl")
    end

    test "encodes usernames in the request path" do
      stub_response(fixture("inventory"), fn conn ->
        assert conn.request_path == "/users/space%20cadet%2F%231/inventory"
      end)

      assert {:ok, %Page{}} = Marketplace.get_inventory("space cadet/#1")
    end

    test "passes options as query parameters" do
      stub_response(fixture("inventory"), fn conn ->
        assert conn.params["sort"] == "price"
        assert conn.params["sort_order"] == "asc"
      end)

      assert {:ok, %Page{}} = Marketplace.get_inventory("360vinyl", sort: "price", sort_order: "asc")
    end

    test "returns invalid argument for empty username" do
      assert {:error, %Error{type: :invalid_argument, message: "username must be a non-empty string"}} =
               Marketplace.get_inventory("")
    end

    test "returns invalid argument for non-string username" do
      assert {:error, %Error{type: :invalid_argument}} = Marketplace.get_inventory(123)
    end
  end

  describe "get_listing/1,2" do
    test "maps listing fields" do
      stub_response(fixture("listing"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/marketplace/listings/172723812"
      end)

      assert {:ok, %Listing{} = listing} = Marketplace.get_listing(172_723_812)
      assert listing.id == 172_723_812
      assert listing.status == "For Sale"
      assert listing.condition == "Mint (M)"
      assert listing.sleeve_condition == "Mint (M)"
      assert listing.allow_offers == false
      assert listing.posted == "2014-07-15T12:55:01-07:00"
      assert listing.ships_from == "United States"
      assert listing.comments == "Brand new... Still sealed!"
      assert listing.audio == false
    end

    test "maps price fields" do
      stub_response(fixture("listing"))

      assert {:ok, %Listing{} = listing} = Marketplace.get_listing(172_723_812)
      assert %Price{currency: "USD", value: 120.0} = listing.price
      assert %Price{currency: "USD", value: 2.5} = listing.shipping_price
    end

    test "maps original_price as raw map" do
      stub_response(fixture("listing"))

      assert {:ok, %Listing{} = listing} = Marketplace.get_listing(172_723_812)
      assert %{"curr_abbr" => "USD", "formatted" => "$120.00", "value" => 120.0} = listing.original_price
    end

    test "maps detailed seller fields" do
      stub_response(fixture("listing"))

      assert {:ok, %Listing{} = listing} = Marketplace.get_listing(172_723_812)

      assert %ListingSeller{
               id: 1_369_620,
               username: "Booms528",
               avatar_url: "https://secure.gravatar.com/avatar/test.jpg",
               shipping: "Buyer responsible for shipping.",
               payment: "PayPal",
               stats: %{"rating" => "100", "stars" => 5.0, "total" => 15}
             } = listing.seller
    end

    test "maps release fields" do
      stub_response(fixture("listing"))

      assert {:ok, %Listing{} = listing} = Marketplace.get_listing(172_723_812)

      assert %ListingRelease{
               id: 5_610_049,
               catalog_number: "541125-1",
               year: 2014,
               description: "LCD Soundsystem - The Long Goodbye"
             } = listing.release
    end

    test "passes curr_abbr as query parameter" do
      stub_response(fixture("listing"), fn conn ->
        assert conn.params["curr_abbr"] == "EUR"
      end)

      assert {:ok, %Listing{}} = Marketplace.get_listing(172_723_812, curr_abbr: "EUR")
    end

    test "returns not_found error" do
      stub_error(404)
      assert {:error, %Error{type: :not_found}} = Marketplace.get_listing(172_723_812)
    end

    test "returns invalid argument for non-integer listing_id" do
      assert {:error, %Error{type: :invalid_argument, message: "listing_id must be a positive integer"}} =
               Marketplace.get_listing("abc")
    end

    test "returns invalid argument for zero listing_id" do
      assert {:error, %Error{type: :invalid_argument}} = Marketplace.get_listing(0)
    end
  end

  describe "create_listing/2" do
    @valid_params %{
      release_id: 1,
      condition: "Mint (M)",
      price: 10.00,
      status: "For Sale"
    }

    test "hits the correct endpoint with auth header and body" do
      stub_response(fixture("new_listing"), fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/marketplace/listings"
        assert {"authorization", "Discogs token=test-token"} in conn.req_headers

        assert conn.body_params == %{
                 "release_id" => 1,
                 "condition" => "Mint (M)",
                 "price" => 10.0,
                 "status" => "For Sale"
               }
      end)

      assert {:ok, %NewListing{}} = Marketplace.create_listing(user_token(), @valid_params)
    end

    test "maps new listing response fields" do
      stub_response(fixture("new_listing"))

      assert {:ok, %NewListing{} = new_listing} = Marketplace.create_listing(user_token(), @valid_params)
      assert new_listing.listing_id == 41_578_241
      assert new_listing.resource_url == "https://api.discogs.com/marketplace/listings/41578241"
    end

    test "returns unauthorized error for nil auth" do
      assert {:error, %Error{type: :unauthorized}} =
               Marketplace.create_listing(nil, @valid_params)
    end

    test "returns invalid argument when params is not a map" do
      assert {:error, %Error{type: :invalid_argument, message: "params must be a map"}} =
               Marketplace.create_listing(user_token(), "not a map")
    end
  end

  describe "update_listing/3" do
    test "hits the correct endpoint with auth header and body" do
      stub_response(%{}, fn conn ->
        assert conn.method == "PUT"
        assert conn.request_path == "/marketplace/listings/172723812"
        assert {"authorization", "Discogs token=test-token"} in conn.req_headers
        assert conn.body_params == %{"price" => 99.99, "status" => "For Sale"}
      end)

      assert :ok = Marketplace.update_listing(user_token(), 172_723_812, %{price: 99.99, status: "For Sale"})
    end

    test "returns :ok on success" do
      stub_response(%{})
      assert :ok = Marketplace.update_listing(user_token(), 172_723_812, %{price: 50.0})
    end

    test "returns unauthorized error for nil auth" do
      assert {:error, %Error{type: :unauthorized}} =
               Marketplace.update_listing(nil, 172_723_812, %{price: 50.0})
    end

    test "returns invalid argument for non-integer listing_id" do
      assert {:error, %Error{type: :invalid_argument, message: "listing_id must be a positive integer"}} =
               Marketplace.update_listing(user_token(), "abc", %{price: 50.0})
    end

    test "returns invalid argument when params is not a map" do
      assert {:error, %Error{type: :invalid_argument, message: "params must be a map"}} =
               Marketplace.update_listing(user_token(), 172_723_812, "not a map")
    end
  end

  describe "delete_listing/2" do
    test "hits the correct endpoint with auth header" do
      stub_response(%{}, fn conn ->
        assert conn.method == "DELETE"
        assert conn.request_path == "/marketplace/listings/172723812"
        assert {"authorization", "Discogs token=test-token"} in conn.req_headers
      end)

      assert :ok = Marketplace.delete_listing(user_token(), 172_723_812)
    end

    test "returns :ok on success" do
      stub_response(%{})
      assert :ok = Marketplace.delete_listing(user_token(), 172_723_812)
    end

    test "returns unauthorized error for nil auth" do
      assert {:error, %Error{type: :unauthorized}} =
               Marketplace.delete_listing(nil, 172_723_812)
    end

    test "returns invalid argument for non-integer listing_id" do
      assert {:error, %Error{type: :invalid_argument, message: "listing_id must be a positive integer"}} =
               Marketplace.delete_listing(user_token(), "abc")
    end

    test "returns invalid argument for zero listing_id" do
      assert {:error, %Error{type: :invalid_argument}} =
               Marketplace.delete_listing(user_token(), 0)
    end
  end
end
