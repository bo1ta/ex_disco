defmodule ExDisco.Marketplace.Price do
  @moduledoc """
  A monetary value with currency code, as returned by Marketplace listing endpoints.
  """

  @enforce_keys [:currency, :value]
  defstruct [:currency, :value]

  @type t :: %__MODULE__{
          currency: String.t(),
          value: float()
        }

  @spec from_api(map() | nil) :: t() | nil
  def from_api(nil), do: nil

  def from_api(data) do
    %__MODULE__{
      currency: data["currency"],
      value: data["value"]
    }
  end
end
