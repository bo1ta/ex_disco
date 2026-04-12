defmodule ExDisco.Auth.OAuthCredentials do
  @moduledoc """
  OAuth 1.0a credentials used to sign Discogs API requests.
  """

  @enforce_keys [:consumer_key, :consumer_secret, :token, :token_secret]
  defstruct [:consumer_key, :consumer_secret, :token, :token_secret]

  @type t :: %__MODULE__{
          consumer_key: String.t(),
          consumer_secret: String.t(),
          token: String.t(),
          token_secret: String.t()
        }
end
