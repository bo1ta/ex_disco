# ExDisco

An Elixir client library for the [Discogs API](https://www.discogs.com/developers/).

Discogs is the largest crowdsourced music database in the world. ExDisco provides a type-safe, ergonomic interface for querying artists, releases, labels, and user profiles, with support for both personal token authentication and full OAuth 1.0a flows.

## Features

- **Resource APIs** — Query artists, releases, labels, and user profiles
- **Global Search** — Search across releases, artists, labels, and masters
- **Type-Safe** — All API responses mapped to Elixir structs with proper typing
- **Flexible Authentication** — Token-based auth for personal use or OAuth 1.0a for multi-user apps
- **Pagination Support** — Built-in pagination for large result sets
- **Error Handling** — Typed error handling with clear error information

## Installation

Add `ex_disco` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_disco, "~> 0.1.0"}
  ]
end
```

## Configuration

ExDisco requires a user agent to identify your application:

```elixir
config :ex_disco, ExDisco,
  user_agent: "my_app/1.0.0 (+https://github.com/me/my_app)"
```

### Authentication

Choose one of two authentication methods:

**Personal Token** — For personal scripts and CLIs:
```elixir
config :ex_disco, ExDisco,
  user_token: "your_personal_token"
```

Get a token at https://www.discogs.com/settings/developers

**OAuth 1.0a** — For apps acting on behalf of multiple users:
```elixir
config :ex_disco, ExDisco,
  consumer_key: "your_consumer_key",
  consumer_secret: "your_consumer_secret"
```

Register your app at https://www.discogs.com/settings/developers

## Quick Start

Fetch an artist by ID:

```elixir
{:ok, %ExDisco.Artists.Artist{} = artist} = ExDisco.Artists.get(1)
```

Fetch a release:

```elixir
{:ok, %ExDisco.Releases.Release{} = release} = ExDisco.Releases.get_release(249504)
```

Search for music:

```elixir
{:ok, page} = ExDisco.Search.query(q: "Thriller", type: :release)
IO.inspect(Enum.count(page.items))
# 42
```

Handle errors:

```elixir
case ExDisco.Artists.get(999999999) do
  {:ok, artist} -> "Found: #{artist.name}"
  {:error, error} -> "Not found: #{error.message}"
end
# "Not found: Discogs request failed with status 404"
```

## Documentation

Full API documentation is available at [HexDocs](https://hexdocs.pm/ex_disco).

The documentation is integrated into the code itself via module and function documentation. Start with the modules in this order:

1. **`ExDisco.Artists`** — Query artist information
2. **`ExDisco.Releases`** — Query release data
3. **`ExDisco.Labels`** — Query label information
4. **`ExDisco.Search`** — Global search across all resources
5. **`ExDisco.Users`** — Query user profiles (requires authentication)
6. **`ExDisco.Auth`** — Full OAuth 1.0a authentication flow
7. **`ExDisco.Request`** — Low-level request builder and execution


## Contributing

Contributions are welcome! Please submit a pull request or open an issue on [GitHub](https://github.com/bo1ta/ex_disco).

## License

MIT — see LICENSE for details
