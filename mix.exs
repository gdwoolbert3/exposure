defmodule Exposure.MixProject do
  use Mix.Project

  @version "0.1.0"

  ################################
  # Public API
  ################################

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def project do
    [
      aliases: aliases(),
      app: :exposure,
      deps: deps(),
      description: description(),
      dialyzer: dialyzer(),
      docs: docs(),
      elixir: "~> 1.16",
      name: "Exposure",
      package: package(),
      preferred_cli_env: preferred_cli_env(),
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  ################################
  # Private API
  ################################

  defp aliases do
    [
      ci: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "test --cover --export-coverage default",
        "dialyzer --format github"
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.36.1", only: :dev, runtime: false},
      {:credo, "~> 1.7.10", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.2.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Simple and lightweight snapshot testing for Elixir.
    """
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "dialyzer/dialyzer.plt"},
      plt_add_apps: [:ex_unit, :mix]
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_url: "https://github.com/gdwoolbert3/exposure",
      authors: ["Gordon Woolbert"]
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Gordon Woolbert"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/gdwoolbert3/exposure"}
    ]
  end

  defp preferred_cli_env do
    [
      ci: :test
    ]
  end
end
