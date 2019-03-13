defmodule Forklift.MixProject do
  use Mix.Project

  def project do
    [
      app: :forklift,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :kaffe],
      mod: {Forklift.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.1"},
      {:kaffe, "~> 1.9.1"},
      {:divo, "~> 0.2.1", only: [:dev, :test, :integration], organization: "smartcolumbus_os"},
      {:prestige, "~> 0.2.0", organization: "smartcolumbus_os"},
      {:mix_test_watch, "~> 0.9.0", only: :dev, runtime: false},
      {:scos_ex, "~> 1.0.0", organization: "smartcolumbus_os"},
      {:placebo, "~> 1.2.1", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:faker, "~> 0.12", only: [:dev, :test]},
      {:distillery, "~> 2.0"}
    ]
  end
end
