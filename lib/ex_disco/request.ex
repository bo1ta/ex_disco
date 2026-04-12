defmodule ExDisco.Request do
  @moduledoc """
  HTTP request builder and executor for the Discogs API.

  Requests are built using a pipeline of builder functions, then dispatched
  with one of the `execute*` functions.

  ## Example

      Request.get("/artists/123")
      |> Request.execute(&Artist.from_api/1)

  """

  alias ExDisco.{API, Error, Page}

  @type response(value) :: {:ok, value} | {:error, Error.t()}

  defstruct method: :get,
            path: "",
            query: [],
            auth: nil,
            body: nil

  @type t :: %__MODULE__{
          method: :get | :post,
          path: String.t(),
          query: keyword(),
          auth: API.auth(),
          body: term()
        }

  # --- Builder ---

  @doc "Construct a GET Request struct with the given path"
  @spec get(String.t()) :: t()
  def get(path), do: %__MODULE__{method: :get, path: path}

  @doc "Construct a POST Request struct with the given path"
  @spec post(String.t()) :: t()
  def post(path), do: %__MODULE__{method: :post, path: path}

  @spec path(t(), String.t()) :: t()
  def path(%__MODULE__{} = request, path) when is_binary(path) do
    %{request | path: path}
  end

  @spec put_query(t(), keyword()) :: t()
  def put_query(%__MODULE__{} = request, query) when is_list(query) do
    %{request | query: request.query ++ query}
  end

  @spec put_auth(t(), API.auth()) :: t()
  def put_auth(%__MODULE__{} = request, auth) do
    %{request | auth: auth}
  end

  # --- Executors ---

  @spec execute(t(), (map() -> value)) :: response(value) when value: var
  def execute(%__MODULE__{} = request, mapper) when is_function(mapper, 1) do
    with {:ok, body} <- exec(request) do
      {:ok, mapper.(body)}
    end
  end

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

  defp normalize({:ok, %Req.Response{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp normalize({:ok, %Req.Response{status: status, body: body}}) do
    {:error, API.api_error(status, body)}
  end

  defp normalize({:error, exception}) do
    {:error, API.transport_error(exception)}
  end
end
