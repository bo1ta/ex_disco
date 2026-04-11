defmodule ExDiscoTest do
  use ExUnit.Case

  doctest ExDisco

  alias ExDisco.{Client, Error, Page, Request}

  test "builds a client with the required user agent" do
    assert {:ok, %Client{} = client} = ExDisco.client(user_agent: "ex_disco/0.1.0")
    assert client.user_agent == "ex_disco/0.1.0"
    assert client.base_url == "https://api.discogs.com"
  end

  test "rejects missing user agent" do
    assert {:error, %NimbleOptions.ValidationError{}} = ExDisco.client([])
  end

  test "builds req request data from the internal builder" do
    client = ExDisco.client!(user_agent: "ex_disco/0.1.0")

    req =
      client
      |> Request.new()
      |> Request.path("/artists/108713")
      |> Request.put_query(page: 2, per_page: 50)
      |> Request.to_req()

    assert req.method == :get
    assert URI.to_string(req.url) == "https://api.discogs.com/artists/108713"
    assert req.options.params == [page: 2, per_page: 50]
    assert req.headers["user-agent"] == ["ex_disco/0.1.0"]
  end

  test "wraps search payloads in a page struct" do
    page =
      struct(Page,
        items: [%{"id" => 1}],
        page: 1,
        pages: 10,
        per_page: 50,
        total: 500,
        raw: %{}
      )

    assert page.total == 500
    assert [%{"id" => 1}] = page.items
  end

  test "normalizes errors" do
    error = %Error{type: :not_found, status: 404, message: "missing", details: %{}}

    assert error.type == :not_found
    assert error.status == 404
  end
end
