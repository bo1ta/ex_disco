defmodule ExDisco.Types.Image do
  @moduledoc """
  A Discogs image — covers both full-size and thumbnail URIs.
  """

  use ExDisco.Resource

  @enforce_keys [:uri]
  defstruct [:uri, :uri150, :resource_url, :type, :width, :height]

  @type t :: %__MODULE__{
          uri: String.t(),
          uri150: String.t() | nil,
          resource_url: String.t() | nil,
          type: String.t() | nil,
          width: pos_integer() | nil,
          height: pos_integer() | nil
        }

  @doc "Extracts the primary image from the images list"
  @spec get_primary_image(list(t())) :: t() | nil
  def get_primary_image(images) when is_list(images) do
    Enum.find(images, &(&1.type == "primary"))
  end

  def get_primary_image(_other), do: nil
end
