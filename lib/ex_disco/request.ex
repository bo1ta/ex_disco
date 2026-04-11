defmodule ExDisco.Request do
  @moduledoc """
  HTTP request builder and executor for the Discogs API.

  Requests are built using a pipeline of builder functions, then dispatched
  with one of the `execute*` functions.

  ## Example

      Request.new()
      |> Request.path("/artists/123")
      |> Request.execute(&Artist.from_api/1)

  """

  alias ExDisco.{API, Error, Page}

  @type response(value) :: {:ok, value} | {:error, Error.t()}

  defstruct method: :get,
            path: "",
            query: [],
            headers: [],
            body: nil

  @type t :: %__MODULE__{
          method: atom(),
          path: String.t(),
          query: keyword(),
          headers: [{binary(), binary()}],
          body: term()
        }

  # --- Builder ---

  @spec new() :: t()
  def new, do: %__MODULE__{}

  @spec method(t(), atom()) :: t()
  def method(%__MODULE__{} = request, method) when is_atom(method) do
    %{request | method: method}
  end

  @spec path(t(), String.t()) :: t()
  def path(%__MODULE__{} = request, path) when is_binary(path) do
    %{request | path: path}
  end

  @spec put_query(t(), keyword()) :: t()
  def put_query(%__MODULE__{} = request, query) when is_list(query) do
    %{request | query: request.query ++ query}
  end

  @spec put_header(t(), binary(), binary()) :: t()
  def put_header(%__MODULE__{} = request, key, value)
      when is_binary(key) and is_binary(value) do
    %{request | headers: [{key, value} | request.headers]}
  end

  # --- Executors ---

  @spec execute(t(), (map() -> value)) :: response(value) when value: var
  def execute(%__MODULE__{} = request, mapper) when is_function(mapper, 1) do
    with {:ok, body} <- exec(request) do
      {:ok, mapper.(body)}
    end
  end

  @spec execute_page(t(), (map() -> value)) :: response(Page.t(value)) when value: var
  def execute_page(%__MODULE__{} = request, mapper) when is_function(mapper, 1) do
    with {:ok, %{"results" => items} = body} <- exec(request) do
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
  def execute_collection(%__MODULE__{} = request, mapper) when is_function(mapper, 1) do
    with {:ok, %Page{items: items}} <- execute_page(request, mapper) do
      {:ok, items}
    end
  end

  # --- Private ---

  @spec exec(t()) :: response(map())
  defp exec(%__MODULE__{} = request) do
    case API.request(request.method, request.path, request.headers, request.query, request.body) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, API.api_error(status, body)}

      {:error, exception} ->
        {:error, API.transport_error(exception)}
    end
  end
end
