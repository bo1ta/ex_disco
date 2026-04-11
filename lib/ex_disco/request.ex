defmodule ExDisco.Request do
  @moduledoc false

  alias ExDisco.API

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

  @spec exec(t()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def exec(%__MODULE__{} = request) do
    API.request(
      request.method,
      request.path,
      request.headers,
      request.query,
      request.body
    )
  end

  @spec run(t()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def run(%__MODULE__{} = request), do: exec(request)
end
