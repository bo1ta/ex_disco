defmodule ExDisco.Client do
  @moduledoc """
  Client configuration for Discogs API requests.

  A client holds reusable settings such as the API base URL and the required
  Discogs `User-Agent` header.
  """

  @enforce_keys [:user_agent]
  defstruct base_url: "https://api.discogs.com",
            user_agent: nil,
            auth: nil,
            req_options: []

  @typedoc "Supported authentication strategies."
  @type auth :: nil | {:user_token, String.t()}

  @type t :: %__MODULE__{
          base_url: String.t(),
          user_agent: String.t(),
          auth: auth(),
          req_options: keyword()
        }

  @schema [
    base_url: [
      type: :string,
      default: "https://api.discogs.com",
      doc: "Base URL for the Discogs API."
    ],
    user_agent: [
      type: :string,
      required: true,
      doc: "User-Agent sent with each request. Discogs requires this."
    ],
    auth: [
      type: {:or, [nil, {:tuple, [:atom, :string]}]},
      default: nil,
      doc: "Authentication strategy. Only `{:user_token, token}` is reserved for now."
    ],
    req_options: [
      type: :keyword_list,
      default: [],
      doc: "Additional options passed to Req."
    ]
  ]

  @doc """
  Builds a client from validated options.

  ## Examples

      iex> ExDisco.Client.new(user_agent: "ex_disco/0.1.0")
      {:ok, %ExDisco.Client{user_agent: "ex_disco/0.1.0"}}

  """
  @spec new(keyword()) :: {:ok, t()} | {:error, NimbleOptions.ValidationError.t()}
  def new(opts) when is_list(opts) do
    with {:ok, validated} <- NimbleOptions.validate(opts, @schema),
         :ok <- validate_auth(validated[:auth]) do
      {:ok, struct(__MODULE__, validated)}
    end
  end

  @doc """
  Same as `new/1`, but raises on invalid options.
  """
  @spec new!(keyword()) :: t()
  def new!(opts) when is_list(opts) do
    case new(opts) do
      {:ok, client} -> client
      {:error, exception} -> raise exception
    end
  end

  defp validate_auth(nil), do: :ok
  defp validate_auth({:user_token, token}) when is_binary(token) and token != "", do: :ok

  defp validate_auth(other) do
    {:error,
     %NimbleOptions.ValidationError{
       key: :auth,
       keys_path: [],
       value: other,
       message:
         "invalid value for :auth option: expected nil or {:user_token, token}, got: #{inspect(other)}"
     }}
  end
end
