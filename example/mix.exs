defmodule MixEmbedBinaries.ExampleMixProject do
  use Mix.Project

  def project do
    [
      app: :mix_embed_binaries_example,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers() ++ [:embed_binaries],
      embed_binaries: ["*.{jpg,png}"]
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
      {:mix_embed_binaries, git: "https://github.com/rlipscombe/mix_embed_binaries.git", runtime: false}
    ]
  end
end
