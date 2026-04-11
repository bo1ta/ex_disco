defmodule ExDisco do
  @moduledoc """
  Elixir client for the Discogs API.

  Start by building a client:

      client = ExDisco.client!(user_agent: "my_app/0.1.0 (+https://example.com)")

  Then call resource helpers:

      ExDisco.artist(client, 108713)
  """

  alias ExDisco.{Client, Error, Page, Request}

  @type response(value) :: {:ok, value} | {:error, Error.t()}

  @doc "Builds a validated client."
  @spec client(keyword()) :: {:ok, Client.t()} | {:error, NimbleOptions.ValidationError.t()}
  def client(opts), do: Client.new(opts)

  @doc "Builds a validated client and raises on invalid options."
  @spec client!(keyword()) :: Client.t()
  def client!(opts), do: Client.new!(opts)

  @doc """
  Fetches an artist by Discogs ID.
  """
  @spec artist(Client.t(), pos_integer()) :: response(map())
  def artist(%Client{} = client, id) when is_integer(id) and id > 0 do
    client
    |> Request.new()
    |> Request.path("/artists/#{id}")
    |> execute()
  end

  @doc """
  Searches the public Discogs database.
  """
  @spec search(Client.t(), keyword()) :: response(Page.t(map()))
  def search(%Client{} = client, params \\ []) when is_list(params) do
    client
    |> Request.new()
    |> Request.path("/database/search")
    |> Request.put_query(params)
    |> execute_page()
  end

  defp execute(%Request{} = request) do
    case Request.run(request) do
      {:ok, %Req.Response{status: status, body: body}}
      when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, api_error(status, body)}

      {:error, exception} ->
        {:error, transport_error(exception)}
    end
  end

  defp execute_page(%Request{} = request) do
    case execute(request) do
      {:ok, %{"results" => items} = body} ->
        pagination = Map.get(body, "pagination", %{})

        {:ok,
         %Page{
           items: items,
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
