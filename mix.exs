defmodule AbsintheQuarry.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://github.com/enewbury/absinthe_quarry"

  def project do
    [
      app: :absinthe_quarry,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],

      # Docs
      name: "AbsintheQuarry",
      description: "Performant GraphQL backends made easy",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
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
      {:absinthe, "~> 1.5", only: [:dev, :test]},
      {:quarry, "~> 0.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:version_release, "~> 0.2.3", only: :dev, runtime: false},
      {:ex_machina, "~> 2.3", only: [:test]},
      {:excoveralls, "~> 0.10", only: :test},
      {:ecto_sqlite3, "~> 0.7", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "ecto.reset": ["ecto.drop", "ecto.create", "ecto.migrate"]
    ]
  end

  defp package() do
    [
      maintainers: ["Eric Newbury"],
      licenses: ["MIT"],
      links: %{"Github" => @source_url}
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "AbsintheQuarry",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/absinthe_quarry",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end
end
