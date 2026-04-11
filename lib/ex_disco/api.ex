defmodule ExDisco.API do
  @moduledoc false

  alias ExDisco.{Config, Error}

  @base_url "https://api.discogs.com"
  @default_user_agent "ex_disco/0.1.0"

  @type method :: :get | :post
  @type headers :: [{String.t(), String.t()}]
  @type query :: keyword()
  @type body :: term()

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

  defp extract_message(%{"message" => message}, _status) when is_binary(message), do: message
  defp extract_message(_body, status), do: "Discogs request failed with status #{status}"

  defp error_type(401), do: :unauthorized
  defp error_type(403), do: :forbidden
  defp error_type(404), do: :not_found
  defp error_type(429), do: :rate_limited
  defp error_type(_status), do: :api_error
end
