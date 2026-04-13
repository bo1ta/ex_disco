defmodule ExDisco.Guards do
  @moduledoc false
  # Internal shared guards

  defguard is_non_empty_binary(value) when is_binary(value) and byte_size(value) > 0

  defguard is_positive_integer(value) when is_integer(value) and value > 0
end
