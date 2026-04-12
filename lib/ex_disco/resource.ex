defmodule ExDisco.Resource do
  @moduledoc """
  Shared behaviour and default implementations for Discogs API resource structs.

  When all struct fields map 1:1 to API response keys, `use ExDisco.Resource`
  provides a default `from_api/1` that maps API response keys directly to struct
  fields, and a default `from_api_list/1`. Both can be overridden when custom mapping is needed.

  ## Example — 1:1 mapping, no overrides needed

      defmodule ExDisco.Users.Identity do
        use ExDisco.Resource
        defstruct [:id, :username, :resource_url]
      end

  ## Example — custom `from_api`, free `from_api_list`

      defmodule ExDisco.Releases.Track do
        use ExDisco.Resource
        defstruct [:title, :position, :duration]

        @impl ExDisco.Resource
        def from_api(data) do
          %__MODULE__{
            title: data["title"],
            position: data["position"],
            duration: presence(data["duration"])
          }
        end
      end
  """

  @callback from_api(map()) :: struct()
  @callback from_api_list(list() | any()) :: [struct()]

  defmacro __using__(_) do
    quote do
      @behaviour ExDisco.Resource

      @impl ExDisco.Resource
      def from_api(data), do: ExDisco.APIMapper.from_api(__MODULE__, data)

      @impl ExDisco.Resource
      def from_api_list(data) when is_list(data), do: Enum.map(data, &from_api/1)
      def from_api_list(_), do: []

      defoverridable from_api: 1, from_api_list: 1
    end
  end
end
