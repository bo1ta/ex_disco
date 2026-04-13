defmodule ExDisco.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_disco,
      version: "0.1.0",
      description: "An Elixir client for the Discogs API",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:oauther, "~> 1.0"},
      {:plug, "~> 1.18", only: :test},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      main: "ExDisco",
      source_url: "https://github.com/bo1ta/ex_disco",
      source_ref: "main",
      groups_for_modules: [
        Authentication: [
          ExDisco.Auth,
          ExDisco.Auth.Authorization,
          ExDisco.Auth.RequestToken
        ],
        Resources: [
          ExDisco.Artists,
          ExDisco.Releases,
          ExDisco.Labels,
          ExDisco.Users,
          ExDisco.Search
        ],
        "Data Structures": [
          ExDisco.Artists.Artist,
          ExDisco.Artists.ArtistAlias,
          ExDisco.Releases.Release,
          ExDisco.Releases.MasterRelease,
          ExDisco.Releases.MasterVersion,
          ExDisco.Releases.Track,
          ExDisco.Releases.Format,
          ExDisco.Releases.Video,
          ExDisco.Releases.Community,
          ExDisco.Releases.ReleaseStats,
          ExDisco.Releases.Rating,
          ExDisco.Labels.Label,
          ExDisco.Users.Profile,
          ExDisco.Users.Identity,
          ExDisco.Types.ReleaseSummary,
          ExDisco.Types.ArtistCredit,
          ExDisco.Types.CreditEntity,
          ExDisco.Types.Image
        ],
        Utilities: [
          ExDisco.Request,
          ExDisco.Page,
          ExDisco.Error,
          ExDisco.Config
        ]
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/bo1ta/ex_disco"
      }
    ]
  end
end
