defmodule ExDisco.API do
  @moduledoc false

  alias ExDisco.Auth.{OAuthCredentials, UserToken}
  alias ExDisco.{Config, Error}

  @type auth :: UserToken.t() | OAuthCredentials.t() | nil

  @spec get(String.t(), keyword(), auth()) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def get(endpoint, query, auth \\ nil) do
    endpoint
    |> build_request(:get, query, nil, auth)
    |> Req.request()
  rescue
    exception in [Req.TransportError] ->
      {:error, exception}
  end

  @spec post(String.t(), term(), auth()) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def post(endpoint, body, auth \\ nil) do
    endpoint
    |> build_request(:post, [], body, auth)
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

    headers =
      [{"user-agent", Config.user_agent()}]
      |> maybe_put_auth(auth || Config.auth(), method, url, query)

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

  defp maybe_put_auth(headers, %UserToken{token: token}, _method, _url, _query) do
    [{"authorization", "Discogs token=#{token}"} | headers]
  end

  defp maybe_put_auth(
         headers,
         %OAuthCredentials{
           consumer_key: consumer_key,
           consumer_secret: consumer_secret,
           token: token,
           token_secret: token_secret
         },
         method,
         url,
         query
       ) do
    credentials =
      OAuther.credentials(
        consumer_key: consumer_key,
        consumer_secret: consumer_secret,
        token: token,
        token_secret: token_secret
      )

    signed = OAuther.sign(method |> to_string() |> String.upcase(), url, query, credentials)
    {header_key, header_value} = oauth_header(signed)
    [{header_key, header_value} | headers]
  end

  defp maybe_put_auth(headers, nil, _method, _url, _query), do: headers

  defp oauth_header(signed) do
    {{header_key, header_value}, _params} = OAuther.header(signed)

    {header_key, header_value}
  end

  defp extract_message(%{"message" => message}, _status) when is_binary(message), do: message
  defp extract_message(_body, status), do: "Discogs request failed with status #{status}"

  defp error_type(401), do: :unauthorized
  defp error_type(403), do: :forbidden
  defp error_type(404), do: :not_found
  defp error_type(429), do: :rate_limited
  defp error_type(_status), do: :api_error
end
