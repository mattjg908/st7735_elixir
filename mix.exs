defmodule St7735Elixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :st7735_elixir,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:circuits_gpio, "~> 1.0.0"},
      {:circuits_spi, "~> 1.2"},
      {:cvt_color, github: "cocoa-xu/cvt_color", branch: "master", only: [:dev, :prod]},
      {:evision, "~> 0.1.0-dev", github: "cocoa-xu/evision", branch: "main"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false, targets: :host}
    ]
  end
end
