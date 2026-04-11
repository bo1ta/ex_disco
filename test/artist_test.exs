defmodule ExDisco.ArtistTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Artists
  alias ExDisco.Artists.{Artist, ArtistAlias}

  alias ExDisco.Types.{Image, ReleaseSummary}

  describe "get/1" do
    test "fetches a single artist by id" do
      Req.Test.expect(__MODULE__, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/artists/108713"
        assert {"user-agent", "ex_disco/0.1.0"} in conn.req_headers

        Req.Test.json(conn, %{
          "id" => 108_713,
          "name" => "Rhadoo",
          "realname" => "Radu Bogdan Cilinca",
          "profile" => "Romanian DJ and producer",
          "resource_url" => "https://api.discogs.com/artists/108713",
          "releases_url" => "https://api.discogs.com/artists/108713/releases",
          "uri" => "https://www.discogs.com/artist/108713-Rhadoo",
          "data_quality" => "Needs Vote",
          "namevariations" => ["DJ Rhadoo", "Bogdan Rhadoo"],
          "aliases" => [
            %{
              "id" => 989_544,
              "name" => "Nea Marin",
              "resource_url" => "https://api.discogs.com/artists/989544"
            }
          ],
          "images" => [
            %{
              "type" => "secondary",
              "uri" => "https://img.discogs.com/secondary.jpg",
              "uri150" => "https://img.discogs.com/secondary_150.jpg",
              "resource_url" => "https://img.discogs.com/secondary.jpg",
              "width" => 600,
              "height" => 800
            },
            %{
              "type" => "primary",
              "uri" => "https://img.discogs.com/primary.jpg",
              "uri150" => "https://img.discogs.com/primary_150.jpg",
              "resource_url" => "https://img.discogs.com/primary.jpg",
              "width" => 499,
              "height" => 683
            }
          ]
        })
      end)

      assert {:ok, %Artist{} = artist} = Artists.get(108_713)
      assert artist.id == 108_713
      assert artist.name == "Rhadoo"
      assert artist.realname == "Radu Bogdan Cilinca"
      assert artist.type == "artist"
      assert artist.data_quality == "Needs Vote"
      assert artist.namevariations == ["DJ Rhadoo", "Bogdan Rhadoo"]
      assert artist.releases_url == "https://api.discogs.com/artists/108713/releases"
      assert artist.uri == "https://www.discogs.com/artist/108713-Rhadoo"

      assert [%ArtistAlias{id: 989_544, name: "Nea Marin"}] = artist.aliases

      assert %Image{
               type: "primary",
               uri: "https://img.discogs.com/primary.jpg",
               uri150: "https://img.discogs.com/primary_150.jpg",
               width: 499,
               height: 683
             } = artist.image

      refute Map.has_key?(Map.from_struct(artist), :raw)
    end

    test "fetches artist with no images returns nil image" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "id" => 1,
          "name" => "Unknown Artist"
        })
      end)

      assert {:ok, %Artist{} = artist} = Artists.get(1)
      assert artist.image == nil
      assert artist.aliases == []
      assert artist.namevariations == []
    end
  end

  describe "search/1" do
    test "searches artists by name using configured defaults" do
      Req.Test.expect(__MODULE__, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/database/search"

        query = URI.decode_query(conn.query_string)

        assert query["type"] == "artist"
        assert query["q"] == "Rhadoo"
        assert query["type"] == "artist"

        Req.Test.json(conn, %{
          "pagination" => %{
            "page" => 1,
            "pages" => 1,
            "per_page" => 50,
            "items" => 1
          },
          "results" => [
            %{
              "id" => 108_713,
              "title" => "Rhadoo",
              "type" => "artist",
              "thumb" => "https://img.discogs.com/rhadoo.jpg",
              "resource_url" => "https://api.discogs.com/artists/108713"
            }
          ]
        })
      end)

      assert {:ok, [%Artist{} = artist]} = Artists.search(q: "Rhadoo")
      assert artist.id == 108_713
      assert artist.name == "Rhadoo"
      assert artist.thumb == "https://img.discogs.com/rhadoo.jpg"
      assert artist.aliases == []
      assert artist.image == nil
    end
  end

  @artist_releases_response %{
    "pagination" => %{"page" => 1, "pages" => 1, "per_page" => 50, "items" => 2},
    "releases" => [
      %{
        "id" => 173_765,
        "title" => "Curb",
        "artist" => "Nickelback",
        "type" => "master",
        "role" => "Main",
        "year" => 1996,
        "thumb" => "https://img.discogs.com/curb.jpg",
        "resource_url" => "http://api.discogs.com/masters/173765",
        "main_release" => 3_128_432
      },
      %{
        "id" => 4_299_404,
        "title" => "Hesher",
        "artist" => "Nickelback",
        "type" => "release",
        "role" => "Main",
        "status" => "Accepted",
        "format" => "CD, EP",
        "label" => "Not On Label",
        "year" => 1996,
        "thumb" => "https://img.discogs.com/hesher.jpg",
        "resource_url" => "http://api.discogs.com/releases/4299404"
      }
    ]
  }

  describe "get_releases/1" do
    test "returns a list of release summaries" do
      Req.Test.expect(__MODULE__, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/artists/108713/releases"

        Req.Test.json(conn, @artist_releases_response)
      end)

      assert {:ok, releases} = Artists.get_releases(108_713)
      assert length(releases) == 2
      assert Enum.all?(releases, &match?(%ReleaseSummary{}, &1))
    end

    test "maps master release fields correctly" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @artist_releases_response)
      end)

      assert {:ok, [master | _]} = Artists.get_releases(108_713)

      assert master.id == 173_765
      assert master.title == "Curb"
      assert master.artist == "Nickelback"
      assert master.type == "master"
      assert master.role == "Main"
      assert master.year == 1996
      assert master.main_release == 3_128_432
      assert master.thumb == "https://img.discogs.com/curb.jpg"
      assert master.catno == nil
      assert master.label == nil
    end

    test "maps release fields correctly" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @artist_releases_response)
      end)

      assert {:ok, [_, release]} = Artists.get_releases(108_713)

      assert release.id == 4_299_404
      assert release.type == "release"
      assert release.status == "Accepted"
      assert release.format == "CD, EP"
      assert release.label == "Not On Label"
      assert release.main_release == nil
    end

    test "returns an empty list when the artist has no releases" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "pagination" => %{"page" => 1, "pages" => 0, "per_page" => 50, "items" => 0},
          "releases" => []
        })
      end)

      assert {:ok, []} = Artists.get_releases(1)
    end
  end
end
