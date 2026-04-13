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

  alias ExDisco.{Error, Page, Request}
  alias ExDisco.Labels.Label
  alias ExDisco.Types.ReleaseSummary

  import ExDisco.Guards, only: [is_positive_integer: 1]

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
  def get(id) when is_positive_integer(id) do
    Request.get("/labels/#{id}")
    |> Request.execute(&Label.from_api/1)
  end

  def get(_), do: Error.invalid_argument("id must be a positive integer")

  @doc """
  Fetch releases published by a label.

  Returns a paginated list of releases from the label. Use the `opts` keyword
  list to control pagination.

  ## Options

  - `:page` — Page number (default: 1)
  - `:per_page` — Items per page (default: 50)

  ## Examples

      iex> ExDisco.Labels.get_releases(1)
      {:ok, %ExDisco.Page{items: [%ExDisco.Types.ReleaseSummary{}, ...], total: 15}}

      iex> ExDisco.Labels.get_releases(1, page: 2, per_page: 25)
      {:ok, %ExDisco.Page{items: [...], page: 2}}
  """
  @spec get_releases(pos_integer(), keyword()) ::
          {:ok, Page.t(ReleaseSummary.t())} | {:error, Error.t()}
  def get_releases(id, opts \\ [])

  def get_releases(id, opts) when is_positive_integer(id) and is_list(opts) do
    Request.get("/labels/#{id}/releases")
    |> Request.put_query(opts)
    |> Request.execute_page("releases", &ReleaseSummary.from_api/1)
  end

  def get_releases(id, _) when not is_positive_integer(id),
    do: Error.invalid_argument("id must be a positive integer")

  def get_releases(_, opts) when not is_list(opts),
    do: Error.invalid_argument("opts must be a list of keywords")
end
