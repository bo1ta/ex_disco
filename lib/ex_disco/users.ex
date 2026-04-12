defmodule ExDisco.Users do
  @moduledoc """
  Query user profile and identity information from Discogs.

  Users represent Discogs community members. You can retrieve basic identity
  information about yourself (when authenticated) or public profile information
  about any user.

  ## Authentication

  These functions require authentication. Pass either:
  - `nil` to use the configured personal token
  - A credential struct from `ExDisco.Auth` for per-user requests

  ## Examples

  Get your identity (requires authentication):

      {:ok, me} = ExDisco.Users.get_identity()
      IO.inspect(me.username)

  Get a user’s public profile:

      {:ok, user} = ExDisco.Users.get_profile("someuser")
      IO.inspect(user.location)

  See `ExDisco.Users.Identity` and `ExDisco.Users.Profile` for data structures.
  """

  alias ExDisco.{Error, Request}
  alias ExDisco.Users.{Identity, Profile}

  @doc """
  Get the authenticated user’s identity.

  Returns basic information about the currently authenticated user. This is a
  good sanity check to verify you’re authenticated correctly. For more detailed
  information, use `get_profile/2`.

  Requires authentication (personal token or OAuth).

  ## Examples

      iex> ExDisco.Users.get_identity()
      {:ok, %ExDisco.Users.Identity{username: "myself", ...}}

      iex> creds = ExDisco.Auth.oauth_credentials(...)
      iex> ExDisco.Users.get_identity(creds)
      {:ok, %ExDisco.Users.Identity{username: "otheruser", ...}}
  """
  @spec get_identity(ExDisco.Auth.t()) :: {:ok, Identity.t()} | {:error, Error.t()}
  def get_identity(auth \\ nil)

  def get_identity(auth) do
    Request.get("/oauth/identity")
    |> Request.put_auth(auth)
    |> Request.execute(&Identity.from_api/1)
  end

  @doc """
  Get a user’s profile by username.

  Returns public profile information about a Discogs user including location,
  collection and wantlist details, and ratings. If authenticated as the user,
  additional private information like email may be visible.

  ## Examples

      iex> ExDisco.Users.get_profile("someuser")
      {:ok, %ExDisco.Users.Profile{username: "someuser", location: "...", ...}}
  """
  @spec get_profile(String.t(), ExDisco.Auth.t()) :: {:ok, Profile.t()} | {:error, Error.t()}
  def get_profile(username, auth \\ nil)

  def get_profile(username, auth) do
    Request.get("/users/#{username}")
    |> Request.put_auth(auth)
    |> Request.execute(&Profile.from_api/1)
  end
end
