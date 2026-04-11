defmodule ExDisco.Request do
  @moduledoc false

  alias ExDisco.Client

  @enforce_keys [:client]
  defstruct client: nil,
            method: :get,
            path: "",
            query: [],
            headers: [],
            body: nil

  @type t :: %__MODULE__{
          client: Client.t(),
          method: atom(),
          path: String.t(),
          query: keyword(),
          headers: [{binary(), binary()}],
          body: term()
        }

  @spec new(Client.t()) :: t()
  def new(%Client{} = client), do: %__MODULE__{client: client}

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

  @spec run(t()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def run(%__MODULE__{} = request) do
    request
    |> to_req()
    |> Req.request()
  rescue
    exception in [Req.TransportError] ->
      {:error, exception}
  end

  @spec to_req(t()) :: Req.Request.t()
  def to_req(%__MODULE__{} = request) do
    client = request.client

    headers =
      request.headers
      |> Enum.reverse()
      |> put_default_header("user-agent", client.user_agent)
      |> maybe_put_auth(client.auth)

    Req.new(
      Keyword.merge(
        client.req_options,
        method: request.method,
        url: client.base_url <> request.path,
        headers: headers,
        params: request.query,
        json: request.body
      )
    )
  end

  defp put_default_header(headers, key, value) do
    if Enum.any?(headers, fn {existing_key, _value} -> String.downcase(existing_key) == key end) do
      headers
    else
      [{key, value} | headers]
    end
  end

  defp maybe_put_auth(headers, {:user_token, token}) do
    put_default_header(headers, "authorization", "Discogs token=#{token}")
  end

  defp maybe_put_auth(headers, nil), do: headers
end
