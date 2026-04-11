defmodule ExDisco.Labels do
  @moduledoc """
  Discogs Label resource
  """

  alias ExDisco.{Request, Error}
  alias ExDisco.Labels.Label
  alias ExDisco.Types.ReleaseSummary

  @spec get(pos_integer()) :: {:ok, Label.t()} | {:error, Error.t()}
  def get(id) when is_integer(id) and id > 0 do
    Request.new()
    |> Request.path("/labels/#{id}")
    |> Request.execute(&Label.from_api/1)
  end

  @doc """
  Fetches a paginated list of releases for a given label ID.
  """
  @spec get_releases(pos_integer()) :: {:ok, [ReleaseSummary.t()]} | {:error, Error.t()}
  def get_releases(id) when is_integer(id) and id > 0 do
    Request.new()
    |> Request.path("/labels/#{id}/releases")
    |> Request.execute_collection("releases", &ReleaseSummary.from_api/1)
  end
end
