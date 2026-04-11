defmodule ExDisco.Labels do
  @moduledoc """
  Discogs Label resource
  """

  alias ExDisco.{Request, Error}
  alias ExDisco.Labels.Label

  @spec get(pos_integer()) :: {:ok, Label.t()} | {:error, Error.t()}
  def get(id) when is_integer(id) and id > 0 do
    Request.new()
    |> Request.path("/labels/#{id}")
    |> Request.execute(&Label.from_api/1)
  end
end
