defmodule ExDisco.APIMapper do
  @moduledoc false

  @doc """
  Builds a struct from a string-keyed API response map.
  Keys that don't correspond to an existing atom are silently ignored,
  as are keys that aren't fields on the target struct.
  """
  @spec from_api(module(), map()) :: struct()
  def from_api(module, data) do
    struct(module, atomize_keys(data))
  end

  defp atomize_keys(data) do
    Enum.flat_map(data, fn {k, v} ->
      case to_existing_atom(k) do
        {:ok, atom} -> [{atom, v}]
        :error -> []
      end
    end)
  end

  defp to_existing_atom(key) when is_atom(key), do: {:ok, key}

  defp to_existing_atom(key) when is_binary(key) do
    {:ok, String.to_existing_atom(key)}
  rescue
    ArgumentError -> :error
  end
end
