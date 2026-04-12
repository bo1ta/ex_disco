defmodule ExDisco.Auth.RequestToken do
  @moduledoc """
  Temporary OAuth request token returned by Discogs during the handshake flow.
  """

  @enforce_keys [:oauth_token, :oauth_token_secret]
  defstruct [:oauth_token, :oauth_token_secret, :oauth_callback_confirmed]

  @type t :: %__MODULE__{
          oauth_token: String.t(),
          oauth_token_secret: String.t(),
          oauth_callback_confirmed: String.t() | nil
        }
end
