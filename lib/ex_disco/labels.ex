defmodule ExDisco.Labels do
  @moduledoc """
  Query label (record company) information from Discogs.

  Labels are record companies, publishers, or other entities that release music.
  Labels can be major corporations or independent publishers. Each label has
  metadata including contact information, sublabels, and a discography.

  ## Examples

  Fetch a record label:

      {:ok, label} = ExDisco.Labels.get(1)
      IO.inspect(label.name)

  Fetch releases from a label:

      {:ok, releases} = ExDisco.Labels.get_releases(1)
      Enum.each(releases, &IO.inspect(&1.title))

  See `ExDisco.Labels.Label` for the label data structure.
  """

  alias ExDisco.{Request, Error}
  alias ExDisco.Labels.Label
  alias ExDisco.Types.ReleaseSummary

  @doc """
  Fetch a label by Discogs ID.

  Returns label information including name, profile, images, contact info,
  parent label (if any), and sublabels.

  ## Examples

      iex> ExDisco.Labels.get(1)
      {:ok, %ExDisco.Labels.Label{id: 1, name: "...", ...}}

      iex> ExDisco.Labels.get(9999999)
      {:error, %ExDisco.Error{type: :not_found}}
  """
  @spec get(pos_integer()) :: {:ok, Label.t()} | {:error, Error.t()}
  def get(id) when is_integer(id) and id > 0 do
    Request.get("/labels/#{id}")
    |> Request.execute(&Label.from_api/1)
  end

  @doc """
  Fetch releases published by a label.

  Returns the first page of releases from the label. If you need pagination
  control, use the Request builder directly with execute_page/2.

  ## Examples

      iex> ExDisco.Labels.get_releases(1)
      {:ok, [%ExDisco.Types.ReleaseSummary{...}, ...]}
  """
  @spec get_releases(pos_integer()) :: {:ok, [ReleaseSummary.t()]} | {:error, Error.t()}
  def get_releases(id) when is_integer(id) and id > 0 do
    Request.get("/labels/#{id}/releases")
    |> Request.execute_collection("releases", &ReleaseSummary.from_api/1)
  end
end
