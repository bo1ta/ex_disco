defmodule ExDisco.ArtistTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.{Artists, Page}
  alias ExDisco.Artists.{Artist, ArtistAlias}

  alias ExDisco.Types.{Image, ReleaseSummary}

  describe "get/1" do
    test "maps artist attributes" do
      stub_response(fixture("artist"))

      assert {:ok, %Artist{} = artist} = Artists.get(263_282)
      assert artist.id == 263_282
      assert artist.name == "Rhadoo"
      assert artist.real_name == "Radu Bogdan Cilinca"
      assert artist.data_quality == "Needs Vote"
      assert artist.name_variations == ["Bogdan Rhadoo", "Colorhadoo", "DJ Rhadoo"]
      assert artist.releases_url == "https://api.discogs.com/artists/263282/releases"
      assert artist.uri == "https://www.discogs.com/artist/263282-Rhadoo"

      assert [%ArtistAlias{id: 989_544, name: "Nea Marin"}] = artist.aliases

      assert [
               %Image{
                 type: "primary",
                 uri: "https://img.discogs.com/primary.jpg",
                 uri150: "https://img.discogs.com/primary_150.jpg",
                 width: 499,
                 height: 683
               }
             ] = artist.images

      refute Map.has_key?(Map.from_struct(artist), :raw)
    end

    test "hits the correct endpoint" do
      stub_response(fixture("artist"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/artists/263282"
      end)

      assert {:ok, %Artist{}} = Artists.get(263_282)
    end

    test "fetches artist with no images returns nil image" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "id" => 1,
          "name" => "Unknown Artist"
        })
      end)

      assert {:ok, %Artist{} = artist} = Artists.get(1)
      assert artist.images == []
      assert artist.aliases == []
      assert artist.name_variations == []
    end
  end

  describe "get_releases/1,2" do
    test "returns a Page of release summaries" do
      stub_response(fixture("artist_releases"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/artists/263282/releases"
      end)

      assert {:ok, %Page{items: items}} = Artists.get_releases(263_282)
      assert length(items) == 2
      assert Enum.all?(items, &match?(%ReleaseSummary{}, &1))
    end

    test "maps master release fields correctly" do
      stub_response(fixture("artist_releases"))

      assert {:ok, %Page{items: [master | _]}} = Artists.get_releases(263_282)

      assert master.id == 905_102
      assert master.title == "Platonic Techno"
      assert master.artist == "Rhadoo"
      assert master.role == "Main"
      assert master.year == 2006
      assert master.thumb == ""
      assert master.catno == nil
      assert master.main_release == nil
      assert master.label == "2LS 2 Dance"
    end

    test "returns an empty list when the artist has no releases" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "pagination" => %{"page" => 1, "pages" => 0, "per_page" => 50, "items" => 0},
          "releases" => []
        })
      end)

      assert {:ok, %Page{items: []}} = Artists.get_releases(1)
    end
  end
end
