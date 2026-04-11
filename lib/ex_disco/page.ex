defmodule ExDisco.Page do
  @moduledoc """
  Pagination wrapper for list endpoints.
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
