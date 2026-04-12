defmodule ExDisco.Page do
  @moduledoc """
  Pagination metadata and items from a list endpoint.

  When you request paginated resources from Discogs, results are returned in a
  Page struct containing both the items and pagination information.

  ## Fields

  - `:items` — List of items returned on this page
  - `:page` — Current page number (1-indexed)
  - `:pages` — Total number of pages available
  - `:per_page` — Number of items per page
  - `:total` — Total number of items across all pages

  ## Usage

  Use `ExDisco.Request.execute_page/2-3` to get paginated results:

      {:ok, page} = ExDisco.Request.get("/artists/1/releases")
      |> ExDisco.Request.execute_page(&ReleaseSummary.from_api/1)

      IO.inspect(page.items)        # [ReleaseSummary, ReleaseSummary, ...]
      IO.inspect(page.page)         # 1
      IO.inspect(page.total)        # Total releases for this artist
      IO.inspect(page.pages)        # Total pages available

  To get just the items without pagination metadata, use `execute_collection/2-3`:

      {:ok, releases} = ExDisco.Request.get("/artists/1/releases")
      |> ExDisco.Request.execute_collection(&ReleaseSummary.from_api/1)
      # releases is a flat list, not wrapped in Page

  ## Pagination Control

  Use query parameters to control pagination:

      {:ok, page} = ExDisco.Request.get("/artists/1/releases")
      |> ExDisco.Request.put_query(page: 2, per_page: 100)
      |> ExDisco.Request.execute_page(&ReleaseSummary.from_api/1)
  """

  @enforce_keys [:items]
  defstruct items: [],
            page: nil,
            pages: nil,
            per_page: nil,
            total: nil

  @type t(item) :: %__MODULE__{
          items: [item],
          page: non_neg_integer() | nil,
          pages: non_neg_integer() | nil,
          per_page: non_neg_integer() | nil,
          total: non_neg_integer() | nil
        }
end
