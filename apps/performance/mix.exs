defmodule Performance.MixProject do
  use Mix.Project

  def project do
    [
      app: :performance,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:combinatorics, "~> 0.1.0", only: [:integration]},
      {:smart_city_test, "~> 0.8", only: [:test, :integration]},
      {:benchee, "~> 1.0", only: [:integration]},
      {:exprof, "~> 0.2.3", only: [:integration]},
      {:retry, "~> 0.13"},
    ]
  end
end
