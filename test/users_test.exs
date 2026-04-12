defmodule ExDisco.UsersTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Error
  alias ExDisco.Users
  alias ExDisco.Users.{Identity, Profile}

  describe "get_identity/1" do
    test "maps identity fields" do
      stub_response(fixture("identity"))
      assert {:ok, %Identity{username: "example"}} = Users.get_identity(user_token())
    end

    test "hits the correct endpoint with auth header" do
      stub_response(fixture("identity"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/oauth/identity"
        assert {"authorization", "Discogs token=test-token"} in conn.req_headers
      end)

      assert {:ok, %Identity{}} = Users.get_identity(user_token())
    end

    test "returns error when no identity exists" do
      stub_error(401)

      assert {:error, %Error{type: :unauthorized, message: "You must authenticate" <> _}} =
               Users.get_identity()
    end
  end

  describe "get_profile/2" do
    test "maps profile fields" do
      stub_response(fixture("profile"))
      assert {:ok, %Profile{username: "rodneyfool"}} = Users.get_profile("rodneyfool")
    end

    test "hits the correct endpoint" do
      stub_response(fixture("profile"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/users/rodneyfool"
      end)

      assert {:ok, %Profile{}} = Users.get_profile("rodneyfool")
    end

    test "returns error when not found" do
      stub_error(404)
      assert {:error, %Error{type: :not_found}} = Users.get_profile("rodneyfool")
    end
  end

  describe "update_profile/3" do
    test "hits the correct endpoint with auth header" do
      stub_response(fixture("profile"), fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/users/memory"
        assert conn.body_params == %{"location" => "Paris", "curr_abbr" => "GBP"}
      end)

      assert {:ok, %Profile{}} =
               Users.update_profile(
                 "memory",
                 %{location: "Paris", curr_abbr: "GBP"},
                 user_token()
               )
    end

    test "returns error for invalid currency" do
      assert {:error, %Error{type: :invalid_argument}} =
               Users.update_profile("memory", %{curr_abbr: "TEST"})
    end
  end
end
