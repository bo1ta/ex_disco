defmodule ExDisco.API do
  @moduledoc """
  Low-level HTTP transport for the Discogs API.

  This module is intentionally dumb. It takes already-shaped request data,
  applies configured defaults, and delegates the actual call to `Req`.
  """

  alias ExDisco.{Config, Error, Page, Request}

  @type method :: :get | :post
  @type headers :: [{String.t(), String.t()}]
  @type query :: keyword()
  @type body :: term()

  @type response(value) :: {:ok, value} | {:error, Error.t()}

  @base_url "https://api.discogs.com"
  @default_user_agent "ex_disco/0.1.0"

  @spec new_request() :: Request.t()
  def new_request, do: Request.new()

  @spec request(method(), String.t(), headers(), query(), body()) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def request(method, endpoint, headers, query, body) do
    method
    |> build_request(endpoint, headers, query, body)
    |> Req.request()
  rescue
    exception in [Req.TransportError] ->
      {:error, exception}
  end

  @spec execute(Request.t(), (map() -> value)) :: response(value) when value: var
  def execute(%Request{} = request, mapper) when is_function(mapper, 1) do
    case exec(request) do
      {:ok, body} -> {:ok, mapper.(body)}
      error -> error
    end
  end

  @spec execute_page(Request.t(), (map() -> value)) :: response(Page.t(value)) when value: var
  def execute_page(%Request{} = request, mapper) when is_function(mapper, 1) do
    case exec(request) do
      {:ok, %{"results" => items} = body} ->
        pagination = Map.get(body, "pagination", %{})

        {:ok,
         %Page{
           items: Enum.map(items, mapper),
           page: pagination["page"],
           pages: pagination["pages"],
           per_page: pagination["per_page"],
           total: pagination["items"],
           raw: body
         }}

      other ->
        other
    end
  end

  @spec execute_collection(Request.t(), (map() -> value)) :: response([value]) when value: var
  def execute_collection(%Request{} = request, mapper) when is_function(mapper, 1) do
    case execute_page(request, mapper) do
      {:ok, %Page{items: items}} -> {:ok, items}
      error -> error
    end
  end

  @spec build_request(method(), String.t(), headers(), query(), body()) :: Req.Request.t()
  defp build_request(method, endpoint, headers, query, body) do
    headers =
      headers
      |> put_default_header("user-agent", Config.resolve(:user_agent, @default_user_agent))
      |> maybe_put_auth(Config.resolve(:auth))

    Req.new(
      Keyword.merge(
        Config.resolve(:req_options, []),
        method: method,
        url: @base_url <> endpoint,
        headers: headers,
        params: query,
        json: body
      )
    )
  end

  @spec exec(Request.t()) :: response(map())
  defp exec(%Request{} = request) do
    case Request.exec(request) do
      {:ok, %Req.Response{status: status, body: body}}
      when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, api_error(status, body)}

      {:error, exception} ->
        {:error, transport_error(exception)}
    end
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

  defp api_error(status, body) do
    %Error{
      type: error_type(status),
      status: status,
      message: extract_message(body, status),
      details: body
    }
  end

  defp transport_error(exception) do
    %Error{
      type: :transport_error,
      status: nil,
      message: Exception.message(exception),
      details: exception
    }
  end

  defp extract_message(%{"message" => message}, _status) when is_binary(message), do: message
  defp extract_message(_body, status), do: "Discogs request failed with status #{status}"

  defp error_type(401), do: :unauthorized
  defp error_type(403), do: :forbidden
  defp error_type(404), do: :not_found
  defp error_type(429), do: :rate_limited
  defp error_type(_status), do: :api_error
end
