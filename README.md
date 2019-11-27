# MixEmbedBinaries

A mix compiler task that allows you to embed binary files in BEAM modules.

## Installation

```
mix archive.install
```

...or...

```
def deps do
  [
    {:mix_embed_binaries, git: "https://github.com/rlipscombe/mix_embed_binaries.git", runtime: false}
  ]
end
```

## Usage

Add this to your compiler list:

```
def application do
  [
    # ...
    compilers: Mix.compilers() ++ [:embed_binaries],
    embed_binaries: ["path/*.{foo,bar}"]
  ]
end
```
