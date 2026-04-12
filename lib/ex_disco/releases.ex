defmodule ExDisco.Releases do
  @moduledoc """
  Discogs Release resource
  """

  alias ExDisco.{Error, Request}
  alias ExDisco.Releases.{Release, Rating, ReleaseStats}

  @doc "Fetches a full release by Discogs ID."
  @spec get(pos_integer()) :: {:ok, Release.t()} | {:error, Error.t()}
  def get(id) when is_integer(id) and id > 0 do
    Request.get("/releases/#{id}")
    |> Request.execute(&Release.from_api/1)
  end

  @doc "Fetches the stats for the given Release ID."
  @spec get_stats(pos_integer()) :: {:ok, ReleaseStats.t()} | {:error, Error.t()}
  def get_stats(id) when is_integer(id) and id > 0 do
    Request.get("/releases/#{id}/stats")
    |> Request.execute(&ReleaseStats.from_api/1)
  end

  @doc "Fetches the rating for the given Release ID"
  @spec get_rating(pos_integer()) :: {:ok, Rating.t()} | {:error, Error.t()}
  def get_rating(id) when is_integer(id) and id > 0 do
    Request.get("/releases/#{id}/rating")
    |> Request.execute(&Rating.from_api/1)
  end
end
