defmodule Quarry.Absinthe.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/enewbury/quarry_absinthe"

  def project do
    [
      app: :quarry_absinthe,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      name: "Quarry.Absinthe",
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
      {:absinthe, "~> 1.5"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      name: "Quarry.Absinthe",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/quarry_absinthe",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end
end
