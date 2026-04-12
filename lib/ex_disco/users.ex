defmodule ExDisco.Users do
  @moduledoc """
  Query user profile and identity information from Discogs.

  Users represent Discogs community members. You can retrieve basic identity
  information about yourself (when authenticated) or public profile information
  about any user.

  ## Authentication

  Functions that require authentication take an `ExDisco.Auth.Authorization`
  as their first argument for easy piping:

      ExDisco.Config.user_token()
      |> ExDisco.Auth.Authorization.for_user_token()
      |> ExDisco.Users.get_identity()

  ## Examples

  Get your identity (requires authentication):

      auth = ExDisco.Auth.Authorization.for_user_token(ExDisco.Config.user_token())
      {:ok, me} = ExDisco.Users.get_identity(auth)
      IO.inspect(me.username)

  Get a user's public profile:

      {:ok, user} = ExDisco.Users.get_profile("someuser")
      IO.inspect(user.location)

  See `ExDisco.Users.Identity` and `ExDisco.Users.Profile` for data structures.
  """

  alias ExDisco.{Error, Request}

  alias ExDisco.Auth.Authorization
  alias ExDisco.Users.{Identity, Profile}

  @doc """
  Get the authenticated user's identity.

  Returns basic information about the currently authenticated user. This is a
  good sanity check to verify you're authenticated correctly. For more detailed
  information, use `get_profile/2`.

  Requires authentication (personal token or OAuth).

  ## Examples

      iex> auth = ExDisco.Auth.Authorization.for_user_token("my_token")
      iex> ExDisco.Users.get_identity(auth)
      {:ok, %ExDisco.Users.Identity{username: "myself", ...}}
  """
  @spec get_identity(Authorization.t()) :: {:ok, Identity.t()} | {:error, Error.t()}
  def get_identity(%Authorization{} = auth) do
    Request.get("/oauth/identity")
    |> Request.put_auth(auth)
    |> Request.execute(&Identity.from_api/1)
  end

  def get_identity(_), do: Error.auth_required()

  @doc """
  Get a user's profile by username.

  Returns public profile information about a Discogs user including location,
  collection and wantlist details, and ratings. If authenticated as the user,
  additional private information like email may be visible.

  ## Examples

      iex> ExDisco.Users.get_profile("someuser")
      {:ok, %ExDisco.Users.Profile{username: "someuser", location: "...", ...}}
  """
  @spec get_profile(String.t()) :: {:ok, Profile.t()} | {:error, Error.t()}
  def get_profile(username) when is_binary(username) do
    Request.get("/users/#{username}")
    |> Request.execute(&Profile.from_api/1)
  end

  def get_profile(_), do: Error.invalid_argument("Username must be a string.")

  @spec get_profile(Authorization.t(), String.t()) :: {:ok, Profile.t()} | {:error, Error.t()}
  def get_profile(%Authorization{} = auth, username) when is_binary(username) do
    Request.get("/users/#{username}")
    |> Request.put_auth(auth)
    |> Request.execute(&Profile.from_api/1)
  end

  def get_profile(nil, _), do: Error.auth_required()

  def get_profile(_, _), do: Error.invalid_argument("Username must be a string")

  @doc """
  Update the authenticated user's profile.

  Pass a map with only the fields you want to change.
  Unset fields are omitted from the request and left unchanged on Discogs.

  Requires authentication as the user being updated.

  ## Examples

      iex> auth = ExDisco.Auth.Authorization.for_user_token("my_token")
      iex> ExDisco.Users.update_profile(auth, "vreon", %{location: "Portland", curr_abbr: "USD"})
      {:ok, %ExDisco.Users.Profile{location: "Portland", ...}}

      iex> ExDisco.Users.update_profile(auth, "vreon", %{curr_abbr: "FAKE"})
      {:error, %ExDisco.Error{type: :invalid_argument, ...}}
  """
  @spec update_profile(Authorization.t(), String.t(), Profile.update()) ::
          {:ok, Profile.t()} | {:error, Error.t()}
  def update_profile(%Authorization{} = auth, username, params)
      when is_binary(username) and is_map(params) do
    with :ok <- Profile.validate_update(params) do
      Request.post("/users/#{username}")
      |> Request.put_body(params)
      |> Request.put_auth(auth)
      |> Request.execute(&Profile.from_api/1)
    end
  end

  def update_profile(nil, _, _), do: Error.auth_required()

  def update_profile(_, _, _), do: Error.invalid_argument()
end
