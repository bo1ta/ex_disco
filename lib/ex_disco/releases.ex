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

  alias ExDisco.{Error, Request}
  alias ExDisco.Releases.{Release, Rating, ReleaseStats}

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
end
