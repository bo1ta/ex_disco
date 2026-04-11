defmodule ExDisco.ArtistTest do
  use ExDisco.ApiCase, async: false

  alias ExDisco.Artists
  alias ExDisco.Artists.Artist
  alias ExDisco.Artists.ArtistAlias
  alias ExDisco.Types.Image

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
