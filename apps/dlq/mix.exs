defmodule Dlq.MixProject do
  use Mix.Project

  def project do
    [
      app: :dlq,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      test_paths: test_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Dlq.Application, []}
    ]
  end

  defp deps do
    [
      {:annotated_retry, in_umbrella: true},
      {:elsa, "~> 0.10.0"},
      {:jason, "~> 1.2"},
      {:credo, "~> 1.0", only: [:dev]},
      {:placebo, "~> 2.0.0-rc.2", only: [:dev, :test]},
      {:properties, in_umbrella: true},
      {:testing, in_umbrella: true, only: [:test]}
    ]
  end

  defp test_paths(:integration), do: ["test/integration"]
  defp test_paths(_), do: ["test/unit"]
end
