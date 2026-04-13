defmodule ExDisco.Request do
  @moduledoc """
  HTTP request builder and executor for the Discogs API.

  The Request module provides a fluent interface for building and executing
  requests against the Discogs API. Use one of the builder functions to start,
  then chain modifiers to customize the request, and finally execute it.

  ## Request Building

  Start with `get/1` or `post/1` to create a request, then use modifiers
  like `put_query/2` and `put_auth/2` to customize it:

      Request.get("/artists/123")
      |> Request.put_auth(token)
      |> Request.execute(&Artist.from_api/1)

  ## Execution

  Use one of three executor functions:

  - `execute/2` — Fetch a single resource. Maps the response to a struct.
  - `execute_page/2-3` — Fetch paginated results. Returns a `Page` struct with pagination info.
  - `execute_collection/2-3` — Fetch all items from a paginated response. Returns a flat list.

  ## Examples

  Fetch a single artist:

      {:ok, artist} = Request.get("/artists/1")
      |> Request.execute(&ExDisco.Artists.Artist.from_api/1)

  Fetch paginated releases with custom query:

      {:ok, page} = Request.get("/artists/1/releases")
      |> Request.put_query(per_page: 50)
      |> Request.execute_page("releases", &ReleaseSummary.from_api/1)

  Make an authenticated request:

      token = ExDisco.Auth.user_token("my_token")
      {:ok, profile} = Request.get("/users/me")
      |> Request.put_auth(token)
      |> Request.execute(&User.Identity.from_api/1)
  """

  alias ExDisco.{API, Error, Page}
  alias ExDisco.Auth.Authorization

  @type method :: :get | :post | :put | :delete

  @type response(value) :: {:ok, value} | {:error, Error.t()}

  defstruct method: :get,
            path: "",
            query: [],
            auth: nil,
            body: nil

  @type t :: %__MODULE__{
          method: method(),
          path: String.t(),
          query: keyword(),
          auth: Authorization.t() | nil,
          body: map() | nil
        }

  @type path_segment :: String.t() | integer()
  @type path_input :: String.t() | [path_segment()]

  # --- Builder ---

  @doc """
  Construct a GET request to the given path.

  ## Examples

      iex> Request.get("/artists/1")
      %ExDisco.Request{method: :get, path: "/artists/1", query: [], auth: nil}
      iex> Request.get(["users", "space cadet/#1"])
      %ExDisco.Request{method: :get, path: "/users/space%20cadet%2F%231", query: [], auth: nil}
  """
  def get(segments) when is_list(segments),
    do: %__MODULE__{method: :get, path: build_path(segments)}

  @spec get(path_input()) :: t()
  def get(path) when is_binary(path), do: %__MODULE__{method: :get, path: path}

  @doc """
  Construct a POST request to the given path.

  ## Examples

      iex> Request.post("/oauth/access_token")
      %ExDisco.Request{method: :post, path: "/oauth/access_token", query: [], auth: nil}
  """
  def post(segments) when is_list(segments),
    do: %__MODULE__{method: :post, path: build_path(segments)}

  @spec post(path_input()) :: t()
  def post(path) when is_binary(path), do: %__MODULE__{method: :post, path: path}

  @doc """
  Construct a PUT request to the given path.

  ## Examples

      iex> Request.put("/releases/249504/rating/memory")
      %ExDisco.Request{method: :put, path: "/releases/249504/rating/memory", query: [], auth: nil}
  """
  def put(segments) when is_list(segments),
    do: %__MODULE__{method: :put, path: build_path(segments)}

  @spec put(path_input()) :: t()
  def put(path) when is_binary(path), do: %__MODULE__{method: :put, path: path}

  @doc """
  Construct a DELETE request to the given path.

  ## Examples

      iex> Request.delete("/releases/249504/rating/memory")
      %ExDisco.Request{method: :delete, path: "/releases/249504/rating/memory", query: [], auth: nil}
  """
  def delete(segments) when is_list(segments),
    do: %__MODULE__{method: :delete, path: build_path(segments)}

  @spec delete(path_input()) :: t()
  def delete(path) when is_binary(path), do: %__MODULE__{method: :delete, path: path}

  @doc """
  Set the request body.

  Used for POST and PUT requests that send a JSON body to the API.

  ## Examples

      iex> Request.post("/users/me") |> Request.put_body(%{location: "Portland"})
      %ExDisco.Request{method: :post, body: %{location: "Portland"}, ...}
  """
  @spec put_body(t(), map()) :: t()
  def put_body(%__MODULE__{} = request, body) when is_map(body) do
    %{request | body: body}
  end

  @doc """
  Add query parameters to the request.

  Query parameters are appended to any existing parameters. Common parameters
  include `per_page`, `page`, `sort`, and resource-specific filters.

  ## Examples

      iex> Request.get("/artists/1/releases")
      iex> |> Request.put_query(per_page: 50, sort: "year")
      %ExDisco.Request{query: [per_page: 50, sort: "year"], ...}
  """
  @spec put_query(t(), keyword()) :: t()
  def put_query(%__MODULE__{} = request, query) when is_list(query) do
    %{request | query: request.query ++ query}
  end

  @doc """
  Add authentication credentials to the request.

  Use ExDisco.Auth to create the credentials. Both personal tokens
  (UserToken) and OAuth credentials (OAuthCredentials) are supported.

  ## Examples

      iex> token = ExDisco.Auth.user_token("my_token")
      iex> Request.get("/users/me") |> Request.put_auth(token)
      %ExDisco.Request{auth: %ExDisco.Auth.UserToken{token: "my_token"}, ...}
  """
  @spec put_auth(t(), Authorization.t() | nil) :: t()
  def put_auth(%__MODULE__{} = request, %Authorization{} = auth) do
    %{request | auth: auth}
  end

  def put_auth(%__MODULE__{} = request, nil), do: request

  # --- Executors ---

  @doc """
  Execute the request and return the body response.

  Sends the request to the Discogs API.

  ## Examples

      iex> Request.delete("/releases/1/rating/memory")
      iex> |> Request.put_auth(auth)
      iex> |> Request.execute()
      {:ok, %{...}}
  """
  @spec execute(t()) :: response(map())
  def execute(%__MODULE__{} = request), do: exec(request)

  @doc """
  Execute the request and map the response to a single value.

  Sends the request to the Discogs API and applies the mapper function
  to transform the JSON response into a struct. Use this for endpoints
  that return a single resource (not paginated).

  ## Examples

      iex> Request.get("/artists/1")
      iex> |> Request.execute(&ExDisco.Artists.Artist.from_api/1)
      {:ok, %ExDisco.Artists.Artist{id: 1, name: "..."}}
  """
  @spec execute(t(), (map() -> value)) :: response(value) when value: var
  def execute(%__MODULE__{} = request, mapper) when is_function(mapper, 1) do
    with {:ok, body} <- exec(request) do
      {:ok, mapper.(body)}
    end
  end

  @doc """
  Execute the request and return a paginated response.

  Wraps items in a Page struct containing pagination metadata (page, pages,
  per_page, total). Use this for endpoints that support pagination. By default,
  looks for items in the "results" key; pass a custom key as the second argument.

  ## Examples

      iex> Request.get("/artists/1/releases")
      iex> |> Request.execute_page(&ReleaseSummary.from_api/1)
      {:ok, %ExDisco.Page{items: [...], page: 1, pages: 3, per_page: 50, total: 123}}

      iex> Request.get("/search")
      iex> |> Request.execute_page("artists", &Artist.from_api/1)
      {:ok, %ExDisco.Page{items: [...], ...}}
  """
  @spec execute_page(t(), (map() -> value)) :: response(Page.t(value)) when value: var
  def execute_page(%__MODULE__{} = request, mapper),
    do: execute_page(request, "results", mapper)

  @spec execute_page(t(), String.t(), (map() -> value)) :: response(Page.t(value)) when value: var
  def execute_page(%__MODULE__{} = request, items_key, mapper)
      when is_binary(items_key) and is_function(mapper, 1) do
    with {:ok, body} <- exec(request) do
      items = Map.get(body, items_key, [])
      pagination = Map.get(body, "pagination", %{})

      {:ok,
       %Page{
         items: Enum.map(items, mapper),
         page: pagination["page"],
         pages: pagination["pages"],
         per_page: pagination["per_page"],
         total: pagination["items"]
       }}
    end
  end

  @doc """
  Execute the request and return all items from the first page as a flat list.

  Convenience function for paginated endpoints when you only care about
  the items, not pagination metadata. By default, looks for items in the
  "results" key; pass a custom key as the second argument.

  ## Examples

      iex> Request.get("/artists/1/releases")
      iex> |> Request.execute_collection(&ReleaseSummary.from_api/1)
      {:ok, [%ReleaseSummary{}, %ReleaseSummary{}, ...]}
  """
  @spec execute_collection(t(), (map() -> value)) :: response([value]) when value: var
  def execute_collection(%__MODULE__{} = request, mapper),
    do: execute_collection(request, "results", mapper)

  @spec execute_collection(t(), String.t(), (map() -> value)) :: response([value]) when value: var
  def execute_collection(%__MODULE__{} = request, items_key, mapper)
      when is_binary(items_key) and is_function(mapper, 1) do
    with {:ok, %Page{items: items}} <- execute_page(request, items_key, mapper) do
      {:ok, items}
    end
  end

  # --- Private ---

  @spec exec(t()) :: response(map())
  defp exec(%__MODULE__{method: :get} = request) do
    normalize(API.get(request.path, request.query, request.auth))
  end

  defp exec(%__MODULE__{method: :post} = request) do
    normalize(API.post(request.path, request.body, request.auth))
  end

  defp exec(%__MODULE__{method: :put} = request) do
    normalize(API.put(request.path, request.body, request.auth))
  end

  defp exec(%__MODULE__{method: :delete} = request) do
    normalize(API.delete(request.path, request.auth))
  end

  defp normalize({:ok, %Req.Response{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp normalize({:ok, %Req.Response{status: status, body: body}}) do
    {:error, API.api_error(status, body)}
  end

  defp normalize({:error, exception}) do
    {:error, API.transport_error(exception)}
  end

  defp build_path(segments) do
    "/" <> Enum.map_join(segments, "/", &encode_path_segment/1)
  end

  defp encode_path_segment(segment) when is_binary(segment) do
    URI.encode(segment, &URI.char_unreserved?/1)
  end

  defp encode_path_segment(segment) when is_integer(segment) do
    Integer.to_string(segment)
  end
end
