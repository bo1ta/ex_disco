defmodule ExDisco.ReleasesTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Releases
  alias ExDisco.Releases.{Community, ReleaseStats, Format, Release, Track, Video}

  alias ExDisco.Types.{ArtistCredit, CreditEntity, Image}

  @response %{
    "id" => 249_504,
    "title" => "Never Gonna Give You Up",
    "status" => "Accepted",
    "country" => "UK",
    "released" => "1987",
    "released_formatted" => "1987",
    "year" => 1987,
    "resource_url" => "https://api.discogs.com/releases/249504",
    "uri" => "https://www.discogs.com/Rick-Astley-Never-Gonna-Give-You-Up/release/249504",
    "thumb" => "https://img.discogs.com/thumb.jpg",
    "master_id" => 96_559,
    "master_url" => "https://api.discogs.com/masters/96559",
    "data_quality" => "Correct",
    "lowest_price" => 0.63,
    "num_for_sale" => 58,
    "estimated_weight" => 60,
    "format_quantity" => 1,
    "date_added" => "2004-04-30T08:10:05-07:00",
    "date_changed" => "2012-12-03T02:50:12-07:00",
    "notes" => "UK Release.",
    "genres" => ["Electronic", "Pop"],
    "styles" => ["Synth-pop"],
    "series" => [],
    "identifiers" => [
      %{"type" => "Barcode", "value" => "5012394144777"}
    ],
    "artists" => [
      %{
        "id" => 72_872,
        "name" => "Rick Astley",
        "anv" => "",
        "role" => "",
        "join" => "",
        "tracks" => "",
        "resource_url" => "https://api.discogs.com/artists/72872"
      }
    ],
    "extraartists" => [
      %{
        "id" => 20_942,
        "name" => "Stock, Aitken & Waterman",
        "anv" => "Stock / Aitken / Waterman",
        "role" => "Producer, Written-By",
        "join" => "",
        "tracks" => "",
        "resource_url" => "https://api.discogs.com/artists/20942"
      }
    ],
    "labels" => [
      %{
        "id" => 895,
        "name" => "RCA",
        "catno" => "PB 41447",
        "entity_type" => "1",
        "resource_url" => "https://api.discogs.com/labels/895"
      }
    ],
    "companies" => [
      %{
        "id" => 82_835,
        "name" => "BMG Records (UK) Ltd.",
        "catno" => "",
        "entity_type" => "13",
        "entity_type_name" => "Phonographic Copyright (p)",
        "resource_url" => "https://api.discogs.com/labels/82835"
      }
    ],
    "formats" => [
      %{
        "name" => "Vinyl",
        "qty" => "1",
        "descriptions" => ["7\"", "Single", "45 RPM"]
      }
    ],
    "tracklist" => [
      %{
        "position" => "A",
        "title" => "Never Gonna Give You Up",
        "duration" => "3:32",
        "type_" => "track"
      },
      %{
        "position" => "B",
        "title" => "Never Gonna Give You Up (Instrumental)",
        "duration" => "3:30",
        "type_" => "track"
      }
    ],
    "images" => [
      %{
        "type" => "primary",
        "uri" => "https://img.discogs.com/primary.jpg",
        "uri150" => "https://img.discogs.com/primary_150.jpg",
        "resource_url" => "https://img.discogs.com/primary.jpg",
        "width" => 600,
        "height" => 600
      }
    ],
    "videos" => [
      %{
        "uri" => "https://www.youtube.com/watch?v=te2jJncBVG4",
        "title" => "Rick Astley - Never Gonna Give You Up (Extended Version)",
        "description" => "Rick Astley - Never Gonna Give You Up (Extended Version)",
        "duration" => 330,
        "embed" => true
      }
    ],
    "community" => %{
      "have" => 252,
      "want" => 42,
      "status" => "Accepted",
      "data_quality" => "Correct",
      "rating" => %{"average" => 3.42, "count" => 45},
      "submitter" => %{
        "username" => "memory",
        "resource_url" => "https://api.discogs.com/users/memory"
      },
      "contributors" => []
    }
  }

  @stats_response %{
    "num_have" => 230,
    "num_want" => 1_000,
    "is_offensive" => false
  }

  describe "get/1" do
    test "hits the correct endpoint" do
      Req.Test.expect(__MODULE__, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/releases/249504"
        assert {"user-agent", "ex_disco/0.1.0"} in conn.req_headers

        Req.Test.json(conn, @response)
      end)

      assert {:ok, %Release{}} = Releases.get(249_504)
    end

    test "maps scalar fields" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

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
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

      assert {:ok, release} = Releases.get(249_504)

      assert [%ArtistCredit{id: 72_872, name: "Rick Astley", anv: nil, role: nil}] =
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
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

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
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

      assert {:ok, release} = Releases.get(249_504)

      assert [%Format{name: "Vinyl", qty: "1", descriptions: ["7\"", "Single", "45 RPM"]}] =
               release.formats
    end

    test "maps tracklist" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

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
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

      assert {:ok, release} = Releases.get(249_504)

      assert [%Image{type: "primary", uri: "https://img.discogs.com/primary.jpg", width: 600}] =
               release.images
    end

    test "maps videos" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

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
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

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
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @response)
      end)

      assert {:ok, release} = Releases.get(249_504)
      assert [%{type: "Barcode", value: "5012394144777"}] = release.identifiers
    end

    test "handles missing optional fields gracefully" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, %{"id" => 1, "title" => "Minimal Release"})
      end)

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
      Req.Test.expect(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{"message" => "Release not found."})
      end)

      assert {:error, error} = Releases.get(999)
      assert error.type == :not_found
      assert error.status == 404
      assert error.message == "Release not found."
    end
  end

  describe "get_stats/1" do
    test "hits the correct endpoint" do
      Req.Test.expect(__MODULE__, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/releases/249504/stats"
        assert {"user-agent", "ex_disco/0.1.0"} in conn.req_headers

        Req.Test.json(conn, @stats_response)
      end)

      assert {:ok, %ReleaseStats{}} = Releases.get_stats(249_504)
    end

    test "maps fields" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @stats_response)
      end)

      assert {:ok, %ReleaseStats{is_offensive: false, num_have: 230, num_want: 1_000}} =
               Releases.get_stats(249_504)
    end
  end
end
