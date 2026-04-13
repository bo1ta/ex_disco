defmodule ExDisco.Releases do
  @moduledoc """
  Query release (album) information from Discogs.

  ## Examples

  Fetch full release details:

      {:ok, release} = ExDisco.Releases.get_release(249504)
      IO.inspect(release.title)

  Get community rating:

      {:ok, rating} = ExDisco.Releases.get_rating(249504)
      IO.inspect(rating.average)

  See `ExDisco.Releases.Release` for the complete data structure.
  """

  alias ExDisco.{Error, Page, Request}
  alias ExDisco.Auth.Authorization

  alias ExDisco.Releases.{MasterRelease, MasterVersion, Release, Rating, ReleaseStats, UserRating}

  @doc """
  Fetch a release by Discogs ID.

  Returns comprehensive release data including title, artists, tracklist,
  formats, condition notes, and community metadata.

  ## Examples

      iex> ExDisco.Releases.get_release(249504)
      {:ok, %ExDisco.Releases.Release{id: 249504, title: "Never Gonna Give You Up", ...}}

      iex> ExDisco.Releases.get_release(9999999)
      {:error, %ExDisco.Error{type: :not_found}}
  """
  @spec get_release(pos_integer()) :: {:ok, Release.t()} | {:error, Error.t()}
  def get_release(id) when is_integer(id) and id > 0 do
    Request.get("/releases/#{id}")
    |> Request.execute(&Release.from_api/1)
  end

  def get_release(_), do: Error.invalid_argument("id must be a positive integer")

  @doc """
  Fetch statistics for a release (view counts, wants, haves).

  Returns aggregate community statistics about how many users have or want
  the release.

  ## Examples

      iex> ExDisco.Releases.get_stats(249504)
      {:ok, %ExDisco.Releases.ReleaseStats{is_offensive: false, num_want: 42, num_have: 156}}
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
  Retrieves the master release given the master release ID
  """
  @spec get_master_release(pos_integer()) :: {:ok, MasterRelease.t()} | {:error, Error.t()}
  def get_master_release(id) when is_integer(id) and id > 0 do
    Request.get("/masters/#{id}")
    |> Request.execute(&MasterRelease.from_api/1)
  end

  def get_master_release(_),
    do: Error.invalid_argument("id must be a positive integer")

  @valid_version_sort ~w(released title format label catno country)
  @valid_sort_order ~w(asc desc)

  @doc """
  Fetch all release versions of a master release.

  Returns a paginated list of every pressing and edition of a master recording.
  Each item is a `MasterVersion` with format, country, label, and community stats.

  ## Options

  - `:page` — Page number to fetch (default: 1)
  - `:per_page` — Items per page (default: 50)
  - `:sort` — Sort field: `released`, `title`, `format`, `label`, `catno`, `country`
  - `:sort_order` — `asc` or `desc`
  - `:format` — Filter by format string (e.g. `"Vinyl"`)
  - `:label` — Filter by label name
  - `:released` — Filter by release year (e.g. `"1993"`)
  - `:country` — Filter by country (e.g. `"Belgium"`)

  ## Examples

      iex> ExDisco.Releases.get_master_versions(1000)
      {:ok, %ExDisco.Page{items: [%ExDisco.Releases.MasterVersion{}, ...], total: 47, pages: 1}}

      iex> ExDisco.Releases.get_master_versions(1000, page: 2, sort: "released", country: "UK")
      {:ok, %ExDisco.Page{items: [...], page: 2, total: 47}}
  """
  @spec get_master_versions(pos_integer(), keyword()) ::
          {:ok, Page.t(MasterVersion.t())} | {:error, Error.t()}
  def get_master_versions(master_id, opts \\ [])

  def get_master_versions(master_id, opts)
      when is_integer(master_id) and master_id > 0 and is_list(opts) do
    with :ok <- validate_version_opts(opts) do
      Request.get("/masters/#{master_id}/versions")
      |> Request.put_query(opts)
      |> Request.execute_page("versions", &MasterVersion.from_api/1)
    end
  end

  def get_master_versions(_, _),
    do: Error.invalid_argument("master_id must be a positive integer")

  defp validate_version_opts(opts) do
    cond do
      Keyword.has_key?(opts, :sort) and opts[:sort] not in @valid_version_sort ->
        Error.invalid_argument(
          "sort must be one of: #{Enum.join(@valid_version_sort, ", ")}"
        )

      Keyword.has_key?(opts, :sort_order) and opts[:sort_order] not in @valid_sort_order ->
        Error.invalid_argument("sort_order must be one of: asc, desc")

      true ->
        :ok
    end
  end

  @doc """
  Retrieves the release's rating for a given username.

  If the user hasn't rated the release, then the rating will be 0.
  """
  @spec get_user_rating(pos_integer(), String.t()) :: {:ok, UserRating.t()} | {:error, Error.t()}
  def get_user_rating(release_id, username) when is_integer(release_id) and release_id > 0 do
    Request.get("/releases/#{release_id}/rating/#{username}")
    |> Request.execute(&UserRating.from_api/1)
  end

  def get_user_rating(_, _), do: Error.invalid_argument("release_id must be a positive integer")

  @doc """
  Updates the release’s rating for a given user and returns the updated user rating.

  Requires authentication (personal token or OAuth).

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

  Requires authentication (personal token or OAuth).
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

  def delete_user_rating(nil, _, _), do: Error.auth_required()

  def delete_user_rating(_, _, _),
    do: Error.invalid_argument("release_id must be a positive integer")
end
