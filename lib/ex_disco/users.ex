defmodule ExDisco.Users do
  @moduledoc """
  Discogs user resources.
  """

  alias ExDisco.{Error, Request, API}
  alias ExDisco.Users.{Identity, Profile}

  @doc """
  Retrieve basic information about the authenticated user.
  You can use this resource to find out who you’re authenticated as, and it also doubles as a good sanity check to ensure that you’re using OAuth correctly.

  For more detailed information, make another request for the user’s Profile.

  Requires authentication — either a personal token configured via `user_token`
  in config, or OAuth credentials passed explicitly for per-user requests.

  ## Examples

      # Personal token (configured in config)
      Users.get_identity()

      # OAuth credentials (per-user)
      Users.get_identity(credentials)

  """
  @spec get_identity(API.auth()) :: {:ok, Identity.t()} | {:error, Error.t()}
  def get_identity(auth \\ nil)

  def get_identity(auth) do
    Request.get("/oauth/identity")
    |> Request.put_auth(auth)
    |> Request.execute(&Identity.from_api/1)
  end

  @doc """
  Retrieve a user by username.

  If authenticated as the requested user, the email key will be visible, and the num_list count will include the user’s private lists.
  If authenticated as the requested user or the user’s collection/wantlist is public, the num_collection / num_wantlist keys will be visible.
  """
  @spec get_profile(String.t(), API.auth()) :: {:ok, Profile.t()} | {:error, Error.t()}
  def get_profile(username, auth \\ nil)

  def get_profile(username, auth) do
    Request.get("/users/#{username}")
    |> Request.put_auth(auth)
    |> Request.execute(&Profile.from_api/1)
  end
end
