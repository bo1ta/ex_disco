defmodule ExDisco.LabelsTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.{Labels, Error, Page}
  alias ExDisco.Labels.Label
  alias ExDisco.Types.{Image, ReleaseSummary}

  describe "get/1" do
    test "maps label attributes" do
      stub_response(fixture("label"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/labels/1"
      end)

      assert {:ok, %Label{} = label} = Labels.get(1)
      assert label.id == 1
      assert label.name == "Planet E"

      assert label.profile ==
               "Classic Techno label from Detroit, USA.\r\n[b]Label owner:[/b] [a=Carl Craig].\r\n"

      assert label.resource_url == "https://api.discogs.com/labels/1"
      assert label.releases_url == "https://api.discogs.com/labels/1/releases"
      assert label.uri == "https://www.discogs.com/label/1-Planet-E"

      assert label.contact_info ==
               "Planet E Communications\r\nP.O. Box 27218\r\nDetroit, 48227, USA\r\n\r\np: 313.874.8729 \r\nf: 313.874.8732\r\n\r\nemail: info AT Planet-e DOT net\r\n"

      assert label.data_quality == "Needs Vote"

      assert label.urls == [
               "http://www.planet-e.net",
               "http://planetecommunications.bandcamp.com",
               "http://twitter.com/planetedetroit"
             ]

      assert [
               %Image{
                 resource_url:
                   "https://api-img.discogs.com/85-gKw4oEXfDp9iHtqtCF5Y_ZgI=/fit-in/132x24/filters:strip_icc():format(jpeg):mode_rgb():quality(96)/discogs-images/L-1-1111053865.png.jpg",
                 type: "primary",
                 uri:
                   "https://api-img.discogs.com/85-gKw4oEXfDp9iHtqtCF5Y_ZgI=/fit-in/132x24/filters:strip_icc():format(jpeg):mode_rgb():quality(96)/discogs-images/L-1-1111053865.png.jpg",
                 width: 132,
                 height: 24
               }
             ] = label.images
    end

    test "returns an error for an unknown label" do
      stub_error(404)
      assert {:error, %Error{type: :not_found}} = Labels.get(999)
    end
  end

  describe "get_releases/1,2" do
    test "returns a Page of release summaries" do
      stub_response(fixture("label_releases"), fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/labels/1/releases"
      end)

      assert {:ok, %Page{items: [release, _]}} = Labels.get_releases(1)
      assert %ReleaseSummary{} = release
    end

    test "maps label release fields correctly" do
      stub_response(fixture("label_releases"))

      assert {:ok, %Page{items: [release, _]}} = Labels.get_releases(1)

      assert release.id == 1018
      assert release.title == "Electro Boogie Vol 2 (The Throwdown)"
      assert release.artist == "Dave Clarke"
      assert release.status == "Accepted"
      assert release.format == "CD, Comp, Mixed"
      assert release.catno == "!K7067cd"
      assert release.year == 1998
    end
  end
end
