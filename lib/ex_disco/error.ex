defmodule ExDisco.Error do
  @moduledoc """
  Structured error information from Discogs API requests.

  When a request fails, the client returns an Error struct with details about
  what went wrong. The `:type` field indicates the category of error, and
  `:message` provides a human-readable description.

  ## Error Types

  - `:unauthorized` — Missing or invalid authentication
  - `:forbidden` — Authenticated but not authorized for this resource
  - `:not_found` — Resource does not exist (HTTP 404)
  - `:rate_limited` — Rate limit exceeded (HTTP 429)
  - `:api_error` — Other API error (HTTP 4xx or 5xx)
  - `:transport_error` — Network or connection error

  ## Fields

  - `:message` — Human-readable error description
  - `:status` — HTTP status code (if applicable)
  - `:type` — Error category (atom)
  - `:details` — Additional error details from the API

  ## Examples

  Handle a 404:

      case ExDisco.Artists.get(999999) do
        {:ok, artist} -> IO.inspect(artist)
        {:error, error} ->
          if error.type == :not_found do
            IO.puts("Artist not found")
          else
            IO.puts("Error: \#{error.message}")
          end
      end

  Handle rate limiting:

      case ExDisco.Search.query([...]) do
        {:ok, results} -> results
        {:error, %ExDisco.Error{type: :rate_limited}} ->
          Process.sleep(3000)  # Wait before retrying
          ExDisco.Search.query([...])
        {:error, error} -> {:error, error}
      end
  """

  defexception [:message, :status, :type, :details]

  @type t :: %__MODULE__{
          message: String.t(),
          status: pos_integer() | nil,
          type: atom(),
          details: term()
        }
end
