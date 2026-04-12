defmodule ExDisco.ReleasesTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Releases.UserRating
  alias ExDisco.{Releases, Error}
  alias ExDisco.Releases.{Community, Rating, ReleaseStats, Format, Release, Track, Video}

  alias ExDisco.Types.{ArtistCredit, CreditEntity, Image}

  describe "get/1" do
    test "hits the correct endpoint" do
      stub_response(fixture("releases"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/releases/249504"
      end)

      assert {:ok, %Release{}} = Releases.get(249_504)
    end

    test "maps scalar fields" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)

      assert release.id == 249_504
      assert release.title == "Never Gonna Give You Up"
      assert release.status == "Accepted"
      assert release.country == "UK"
      assert release.released == "1987"
      assert release.year == 1987
      assert release.master_id == 96_559
      assert release.data_quality == "Correct"
      assert release.lowest_price == 0.63
      assert release.num_for_sale == 58
      assert release.genres == ["Electronic", "Pop"]
      assert release.styles == ["Synth-pop"]
    end

    test "maps artists and extraartists" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)

      assert [%ArtistCredit{id: 72_872, name: "Rick Astley", anv: "", role: ""}] =
               release.artists

      assert [
               %ArtistCredit{
                 id: 20_942,
                 anv: "Stock / Aitken / Waterman",
                 role: "Producer, Written-By"
               }
             ] =
               release.extraartists
    end

    test "maps labels and companies as credit entities" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)

      assert [%CreditEntity{id: 895, name: "RCA", catno: "PB 41447", entity_type_name: nil}] =
               release.labels

      assert [
               %CreditEntity{
                 id: 82_835,
                 name: "BMG Records (UK) Ltd.",
                 entity_type_name: "Phonographic Copyright (p)"
               }
             ] =
               release.companies
    end

    test "maps formats" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)

      assert [%Format{name: "Vinyl", qty: "1", descriptions: ["7\"", "Single", "45 RPM"]}] =
               release.formats
    end

    test "maps tracklist" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)

      assert [
               %Track{
                 position: "A",
                 title: "Never Gonna Give You Up",
                 duration: "3:32",
                 type: "track"
               },
               %Track{
                 position: "B",
                 title: "Never Gonna Give You Up (Instrumental)",
                 duration: "3:30"
               }
             ] = release.tracklist
    end

    test "maps images" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)

      assert [%Image{type: "primary", uri: "https://img.discogs.com/primary.jpg", width: 600}] =
               release.images
    end

    test "maps videos" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)

      assert [
               %Video{
                 uri: "https://www.youtube.com/watch?v=te2jJncBVG4",
                 duration: 330,
                 embed: true
               }
             ] = release.videos
    end

    test "maps community stats" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)

      assert %Community{
               have: 252,
               want: 42,
               status: "Accepted",
               rating_average: 3.42,
               rating_count: 45,
               submitter: "memory"
             } = release.community
    end

    test "maps identifiers" do
      stub_response(fixture("releases"))

      assert {:ok, release} = Releases.get(249_504)
      assert [%{type: "Barcode", value: "5012394144777"}] = release.identifiers
    end

    test "handles missing optional fields gracefully" do
      stub_response(%{"id" => 1, "title" => "Minimal Release"})

      assert {:ok, release} = Releases.get(1)

      assert release.id == 1
      assert release.title == "Minimal Release"
      assert release.community == nil
      assert release.artists == []
      assert release.tracklist == []
      assert release.images == []
      assert release.videos == []
      assert release.genres == []
      assert release.identifiers == []
    end

    test "returns an error for an unknown release" do
      stub_error(404)
      assert {:error, %Error{type: :not_found}} = Releases.get(999)
    end
  end

  describe "get_stats/1" do
    test "hits the correct endpoint" do
      stub_response(fixture("release_stats"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/releases/249504/stats"
      end)

      assert {:ok, %ReleaseStats{}} = Releases.get_stats(249_504)
    end

    test "maps fields" do
      stub_response(fixture("release_stats"))

      assert {:ok, %ReleaseStats{is_offensive: false, num_have: 230, num_want: 1_000}} =
               Releases.get_stats(249_504)
    end
  end

  describe "get_rating/1" do
    test "hits the correct endpoint" do
      stub_response(fixture("release_rating"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/releases/249504/rating"
      end)

      assert {:ok, %Rating{}} = Releases.get_rating(249_504)
    end

    test "maps fields" do
      stub_response(fixture("release_rating"))

      assert {:ok, %Rating{count: 227, average: 3.82}} = Releases.get_rating(249_504)
    end
  end

  describe "get_user_rating/2" do
    test "hits the correct endpoint" do
      stub_response(fixture("user_rating"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/releases/249504/rating/memory"
      end)

      assert {:ok, %UserRating{}} = Releases.get_user_rating(249_504, "memory")
    end

    test "maps fields" do
      stub_response(fixture("user_rating"))

      assert {:ok, %UserRating{} = user_rating} = Releases.get_user_rating(249_504, "memory")
      assert user_rating.username == "memory"
      assert user_rating.release_id == 249_504
      assert user_rating.rating == 5
    end
  end

  describe "delete_user_rating/3" do
    test "hits the correct endpoint with auth header" do
      stub_response(%{}, fn conn ->
        assert conn.method == "DELETE"
        assert conn.request_path == "/releases/249504/rating/memory"
        assert {"authorization", "Discogs token=test-token"} in conn.req_headers
      end)

      assert :ok = Releases.delete_user_rating(user_token(), 249_504, "memory")
    end
  end
end
