defmodule ExDisco.LabelsTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Labels
  alias ExDisco.Labels.Label
  alias ExDisco.Types.{Image, ReleaseSummary}

  describe "get/1" do
    test "fetches a single label by id" do
      Req.Test.expect(__MODULE__, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/labels/1"
        assert {"user-agent", "ex_disco/0.1.0"} in conn.req_headers

        Req.Test.json(conn, %{
          "id" => 1,
          "name" => "Fabric",
          "profile" => "London-based nightclub and record label.",
          "resource_url" => "https://api.discogs.com/labels/1",
          "releases_url" => "https://api.discogs.com/labels/1/releases",
          "uri" => "https://www.discogs.com/label/1-Fabric",
          "contact_info" => "77a Charterhouse Street, London",
          "data_quality" => "Correct",
          "urls" => ["https://fabriclondon.com"],
          "images" => [
            %{
              "type" => "primary",
              "uri" => "https://img.discogs.com/fabric_primary.jpg",
              "uri150" => "https://img.discogs.com/fabric_primary_150.jpg",
              "resource_url" => "https://img.discogs.com/fabric_primary.jpg",
              "width" => 600,
              "height" => 400
            },
            %{
              "type" => "secondary",
              "uri" => "https://img.discogs.com/fabric_secondary.jpg",
              "uri150" => "https://img.discogs.com/fabric_secondary_150.jpg",
              "resource_url" => "https://img.discogs.com/fabric_secondary.jpg",
              "width" => 300,
              "height" => 200
            }
          ]
        })
      end)

      assert {:ok, %Label{} = label} = Labels.get(1)
      assert label.id == 1
      assert label.name == "Fabric"
      assert label.profile == "London-based nightclub and record label."
      assert label.resource_url == "https://api.discogs.com/labels/1"
      assert label.releases_url == "https://api.discogs.com/labels/1/releases"
      assert label.uri == "https://www.discogs.com/label/1-Fabric"
      assert label.contact_info == "77a Charterhouse Street, London"
      assert label.data_quality == "Correct"
      assert label.urls == ["https://fabriclondon.com"]

      assert [
               %Image{
                 type: "primary",
                 uri: "https://img.discogs.com/fabric_primary.jpg",
                 width: 600,
                 height: 400
               },
               %Image{
                 type: "secondary",
                 uri: "https://img.discogs.com/fabric_secondary.jpg",
                 width: 300,
                 height: 200
               }
             ] = label.images
    end

    test "fetches a label with no optional fields" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, %{
          "id" => 2,
          "name" => "Unknown Label"
        })
      end)

      assert {:ok, %Label{} = label} = Labels.get(2)
      assert label.id == 2
      assert label.name == "Unknown Label"
      assert label.contact_info == nil
      assert label.images == []
      assert label.urls == []
    end

    test "returns an error for an unknown label" do
      Req.Test.expect(__MODULE__, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{"message" => "Label not found."})
      end)

      assert {:error, error} = Labels.get(999)
      assert error.type == :not_found
      assert error.status == 404
      assert error.message == "Label not found."
    end
  end

  @label_releases_response %{
    "pagination" => %{"page" => 1, "pages" => 68, "per_page" => 5, "items" => 338},
    "releases" => [
      %{
        "id" => 2801,
        "title" => "DJ-Kicks",
        "artist" => "Andrea Parker",
        "status" => "Accepted",
        "format" => "CD, Mixed",
        "catno" => "!K7071CD",
        "year" => 1998,
        "thumb" => "https://img.discogs.com/djkicks.jpg",
        "resource_url" => "http://api.discogs.com/releases/2801"
      }
    ]
  }

  describe "get_releases/1" do
    test "returns a list of release summaries" do
      Req.Test.expect(__MODULE__, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/labels/1/releases"

        Req.Test.json(conn, @label_releases_response)
      end)

      assert {:ok, [release]} = Labels.get_releases(1)
      assert %ReleaseSummary{} = release
    end

    test "maps label release fields correctly" do
      Req.Test.expect(__MODULE__, fn conn ->
        Req.Test.json(conn, @label_releases_response)
      end)

      assert {:ok, [release]} = Labels.get_releases(1)

      assert release.id == 2801
      assert release.title == "DJ-Kicks"
      assert release.artist == "Andrea Parker"
      assert release.status == "Accepted"
      assert release.format == "CD, Mixed"
      assert release.catno == "!K7071CD"
      assert release.year == 1998
      assert release.type == nil
      assert release.role == nil
      assert release.main_release == nil
    end
  end
end
