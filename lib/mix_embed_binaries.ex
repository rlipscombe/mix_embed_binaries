defmodule Mix.Tasks.Compile.EmbedBinaries do
  use Mix.Task

  @recursive true

  @shortdoc "Embed binary resources in modules"

  def run(_args) do
    Mix.Task.run("loadpaths")
    Mix.Project.build_structure()

    output_ebin_dir = Mix.Project.compile_path()

    config = Mix.Project.config()
    patterns = config[:embed_binaries] || []

    inputs =
      Enum.flat_map(patterns, fn pattern ->
        Path.wildcard(pattern)
      end)

    for input <- inputs do
      module = input |> Path.basename() |> String.replace(".", "_")
      output_beam = Path.join(output_ebin_dir, module <> ".beam")

      if Mix.Utils.stale?([input], [output_beam]) do
        EmbedBinary.embed(input, output_beam, module, [:debug_info])
      end
    end

    :ok
  end
end

defmodule EmbedBinary do
  def embed(input, output, module, compiler_options) do
    bytes = File.read!(input)

    # We'll export a function Mod:bin/0.
    mod = String.to_atom(module)
    fun = :bin

    # An Erlang module is a list of forms:
    forms = [
      # -module(foo).
      module_form(1, mod),
      # -export([bin/0]).
      export_form(2, fun),
      # bin() -> <<...>>.
      function_form(3, fun, bytes)
    ]

    # Compile the forms into a binary.
    {:ok, ^mod, bin} = :compile.forms(forms, compiler_options)

    # The binary _is_ the beam file, so write it out.
    :ok = File.write!(output, bin)
  end

  defp module_form(l, mod),
    do: {:attribute, l, :module, mod}

  defp export_form(l, fun),
    do: {:attribute, l, :export, [{fun, 0}]}

  defp function_form(l, fun, binary),
    do: {:function, l, fun, 0, [function_clause(l, [binary_expression(l, binary)])]}

  defp function_clause(l, exprs),
    do: {:clause, l, [], [], exprs}

  defp binary_expression(l, binary) do
    {:bin, l,
     for <<byte::8 <- binary>> do
       # made up of the stuff we first thought of.
       {:bin_element, l, {:integer, l, byte}, :default, :default}
     end}
  end
end
