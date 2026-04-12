defmodule ExDisco.Releases do
  @moduledoc """
  Query release (album) information from Discogs.

  A Release represents a specific pressing or version of a recorded work. Unlike
  a Master Release (the abstract work), a Release has concrete details like
  format (vinyl, CD, cassette), country of origin, release date, catalog numbers,
  and tracklist.

  ## Examples

  Fetch full release details:

      {:ok, release} = ExDisco.Releases.get(249504)
      IO.inspect(release.title)

  Get community rating:

      {:ok, rating} = ExDisco.Releases.get_rating(249504)
      IO.inspect(rating.average)

  See `ExDisco.Releases.Release` for the complete data structure.
  """

  alias ExDisco.{Request, Error}
  alias ExDisco.Auth.Authorization
  alias ExDisco.Releases.{Release, Rating, ReleaseStats, UserRating}

  @doc """
  Fetch a release by Discogs ID.

  Returns comprehensive release data including title, artists, tracklist,
  formats, condition notes, and community metadata.

  ## Examples

      iex> ExDisco.Releases.get(249504)
      {:ok, %ExDisco.Releases.Release{id: 249504, title: "Never Gonna Give You Up", ...}}

      iex> ExDisco.Releases.get(9999999)
      {:error, %ExDisco.Error{type: :not_found}}
  """
  @spec get(pos_integer()) :: {:ok, Release.t()} | {:error, Error.t()}
  def get(id) when is_integer(id) and id > 0 do
    Request.get("/releases/#{id}")
    |> Request.execute(&Release.from_api/1)
  end

  def get(_), do: Error.invalid_argument("id must be a positive integer")

  @doc """
  Fetch statistics for a release (view counts, wants, haves).

  Returns aggregate community statistics about how many users have or want
  the release.

  ## Examples

      iex> ExDisco.Releases.get_stats(249504)
      {:ok, %ExDisco.Releases.ReleaseStats{rating: ..., wants: 42, haves: 156}}
  """
  @spec get_stats(pos_integer()) :: {:ok, ReleaseStats.t()} | {:error, Error.t()}
  def get_stats(id) when is_integer(id) and id > 0 do
    Request.get("/releases/#{id}/stats")
    |> Request.execute(&ReleaseStats.from_api/1)
  end

  def get_stats(_), do: Error.invalid_argument("id must be a positive integer")

  @doc """
  Fetch the community rating for a release.

  Returns the average rating and vote count from the Discogs community.

  ## Examples

      iex> ExDisco.Releases.get_rating(249504)
      {:ok, %ExDisco.Releases.Rating{average: 4.2, count: 87}}
  """
  @spec get_rating(pos_integer()) :: {:ok, Rating.t()} | {:error, Error.t()}
  def get_rating(id) when is_integer(id) and id > 0 do
    Request.get("/releases/#{id}/rating")
    |> Request.execute(&Rating.from_api/1)
  end

  def get_rating(_), do: Error.invalid_argument("id must be a positive integer")

  @doc """
  Retrieves the release's rating for a given username.
  If the user hasn't rated the release, then the rating will be 0.

  ## Examples

      iex> ExDisco.Releases.get_user_rating(249504, "someusername")
      {:ok,
      %ExDisco.Releases.UserRating{
        username: "someusername",
        release_id: 249504,
        rating: 5
      }}
  """
  @spec get_user_rating(pos_integer(), String.t()) :: {:ok, UserRating.t()} | {:error, Error.t()}
  def get_user_rating(release_id, username) when is_integer(release_id) and release_id > 0 do
    Request.get("/releases/#{release_id}/rating/#{username}")
    |> Request.execute(&UserRating.from_api/1)
  end

  def get_user_rating(_, _), do: Error.invalid_argument("release_id must be a positive integer")

  @doc """
  Updates the release’s rating for a given user and returns the updated user rating.

  Requires authentication (personal token or OAuth). Pass the auth as the first
  argument for easy piping.

  ## Examples

      iex> auth = ExDisco.Auth.Authorization.for_user_token("my_token")
      iex> ExDisco.Releases.put_user_rating(auth, 249504, "someusername", 5)
      {:ok,
      %ExDisco.Releases.UserRating{
        username: "someusername",
        release_id: 249504,
        rating: 5
      }}
  """
  @spec put_user_rating(Authorization.t(), pos_integer(), String.t(), pos_integer()) ::
          {:ok, UserRating.t()} | {:error, Error.t()}
  def put_user_rating(%Authorization{} = auth, release_id, username, rating)
      when is_integer(release_id) and release_id > 0 and is_integer(rating) and rating in 1..5 do
    Request.put("/releases/#{release_id}/rating/#{username}")
    |> Request.put_auth(auth)
    |> Request.put_body(%{release_id: release_id, username: username, rating: rating})
    |> Request.execute(&UserRating.from_api/1)
  end

  def put_user_rating(_, _, _, rating) when is_integer(rating) and rating not in 1..5,
    do: Error.invalid_argument("rating must be between 1 and 5")

  def put_user_rating(_, _, _, _),
    do: Error.invalid_argument("release_id must be a positive integer")

  @doc """
  Deletes the release’s rating for a given user.

  Requires authentication (personal token or OAuth). Pass the auth as the first
  argument for easy piping.

  ## Examples

      iex> auth = ExDisco.Auth.Authorization.for_user_token("my_token")
      iex> ExDisco.Releases.delete_user_rating(auth, 249504, "someusername")
      :ok
  """
  @spec delete_user_rating(Authorization.t(), pos_integer(), String.t()) ::
          :ok | {:error, Error.t()}
  def delete_user_rating(%Authorization{} = auth, release_id, username)
      when is_integer(release_id) and release_id > 0 do
    with {:ok, _} <-
           Request.delete("/releases/#{release_id}/rating/#{username}")
           |> Request.put_auth(auth)
           |> Request.execute() do
      :ok
    end
  end

  def delete_user_rating(_, _, _),
    do: Error.invalid_argument("release_id must be a positive integer")
end
