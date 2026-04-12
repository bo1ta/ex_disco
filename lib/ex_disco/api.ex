defmodule ExDisco.API do
  @moduledoc false

  alias ExDisco.Auth.Authorization
  alias ExDisco.{Config, Error}

  @spec get(String.t(), keyword(), Authorization.t() | nil) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def get(endpoint, query, auth \\ nil) do
    endpoint
    |> build_request(:get, query, nil, auth)
    |> Req.request()
  rescue
    exception in [Req.TransportError] ->
      {:error, exception}
  end

  @spec post(String.t(), term(), Authorization.t() | nil) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def post(endpoint, body, auth \\ nil) do
    endpoint
    |> build_request(:post, [], body, auth)
    |> Req.request()
  rescue
    exception in [Req.TransportError] ->
      {:error, exception}
  end

  @spec put(String.t(), term(), Authorization.t() | nil) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def put(endpoint, body, auth \\ nil) do
    endpoint
    |> build_request(:put, [], body, auth)
    |> Req.request()
  rescue
    exception in [Req.TransportError] ->
      {:error, exception}
  end

  @spec delete(String.t(), Authorization.t() | nil) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def delete(endpoint, auth) do
    endpoint
    |> build_request(:delete, [], nil, auth)
    |> Req.request()
  rescue
    exception in [Req.TransportError] ->
      {:error, exception}
  end

  @spec api_error(integer(), term()) :: Error.t()
  def api_error(status, body) do
    %Error{
      type: error_type(status),
      status: status,
      message: extract_message(body, status),
      details: body
    }
  end

  @spec transport_error(Exception.t()) :: Error.t()
  def transport_error(exception) do
    %Error{
      type: :transport_error,
      status: nil,
      message: Exception.message(exception),
      details: exception
    }
  end

  defp build_request(endpoint, method, query, body, auth) do
    url = Config.base_url() <> endpoint

    auth_header = Authorization.to_header(auth, method, url, query)

    headers =
      if auth_header do
        [{"user-agent", Config.user_agent()}, auth_header]
      else
        [{"user-agent", Config.user_agent()}]
      end

    Req.new(
      Keyword.merge(
        Config.req_options(),
        method: method,
        url: url,
        headers: headers,
        params: query,
        json: body
      )
    )
  end

  defp extract_message(%{"message" => message}, _status) when is_binary(message), do: message
  defp extract_message(_body, status), do: "Discogs request failed with status #{status}"

  defp error_type(401), do: :unauthorized
  defp error_type(403), do: :forbidden
  defp error_type(404), do: :not_found
  defp error_type(429), do: :rate_limited
  defp error_type(_status), do: :api_error
end
