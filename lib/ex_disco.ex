defmodule ExDisco do
  @moduledoc """
  Elixir client for the Discogs API.

  Configure it in your app:

      config :ex_disco, ExDisco,
        user_agent: "my_app/0.1.0 (+https://example.com)"

  Then call resource modules directly:

      ExDisco.Artist.get(108713)
      ExDisco.Artist.get(name: "Rhadoo")
  """
end
