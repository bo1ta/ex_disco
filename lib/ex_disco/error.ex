defmodule ExDisco.Error do
  @moduledoc """
  Normalized error returned by the client.
  """

  defexception [:message, :status, :type, :details]

  @type t :: %__MODULE__{
          message: String.t(),
          status: pos_integer() | nil,
          type: atom(),
          details: term()
        }
end
