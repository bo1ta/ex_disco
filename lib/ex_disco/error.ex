defmodule ExDisco.Error do
  @moduledoc """
  Structured error information from Discogs API requests.

  When a request fails, the client returns an Error struct with details about
  what went wrong. The `:type` field indicates the category of error, and
  `:message` provides a human-readable description.

  ## Error Types

  - `:invalid_argument` — Bad input (wrong type, out of range, etc.)
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

  @doc """
  Returns an `{:error, t()}` tuple for invalid arguments.

  Use this as a catch-all clause on functions with guard constraints to return
  a structured error instead of raising a `FunctionClauseError`.

  ## Examples

      def get(id) when is_integer(id) and id > 0, do: ...
      def get(_), do: Error.invalid_argument("id must be a positive integer")

      def put_rating(_, _, rating, _) when rating not in 1..5,
        do: Error.invalid_argument("rating must be between 1 and 5")
      def put_rating(_, _, _, _), do: Error.invalid_argument()
  """
  @spec invalid_argument(String.t()) :: {:error, t()}
  def invalid_argument(message \\ "Invalid argument") do
    {:error, %__MODULE__{type: :invalid_argument, message: message}}
  end
end
