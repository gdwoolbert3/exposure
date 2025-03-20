defmodule Exposure do
  @moduledoc """
  `Exposure` adds support for snapshot testing to Elixir projects.

  For more information, see [Usage](README.md#usage).

  TODO(Gordon) - update dialyzer CI cache
  """

  @dialyzer {:no_match, maybe_add_default_path: 1}

  @inspect_opts %Inspect.Opts{
    printable_limit: :infinity,
    limit: :infinity,
    pretty: true
  }

  @snapshot_directory Application.compile_env(:exposure, :snapshot_directory, "_snapshots")
  @snapshot_test_tag Application.compile_env(:exposure, :snapshot_test_tag, :snapshot)
  @test_paths Keyword.get(Mix.Project.config(), :test_paths, [])

  ################################
  # Public API
  ################################

  @doc false
  @spec handle_snapshot!(term(), Macro.Env.t()) :: :ok
  def handle_snapshot!(value, env) do
    {function_name, _} = env.function
    snapshot_file = snapshot_file!(env.file, function_name)

    cond do
      System.get_env("EXPOSURE_OVERRIDE") == "true" ->
        create_snapshot!(snapshot_file, value)

      File.exists?(snapshot_file) ->
        compare_snapshot!(snapshot_file, value)

      true ->
        raise RuntimeError, "No snapshot for test: \"#{function_name}\"."
    end
  end

  @doc """
  Defines a snapshot test.

  ## Examples

  ```elixir
  describe "my_fun/2" do
    test_snapshot "works as expected" do
      my_fun("foo", 123)
    end
  end
  ```
  """
  @spec test_snapshot(binary(), keyword()) :: Macro.t()
  defmacro test_snapshot(name, opts) do
    expr = Keyword.fetch!(opts, :do)

    quote do
      @tag unquote(@snapshot_test_tag)
      test unquote(name) do
        handle_snapshot!(unquote(expr), __ENV__)
      end
    end
  end

  @doc """
  Defines a snapshot test that utilizes the test context.

  ## Examples

  ```elixir
  describe "my_fun/3" do
    test_snapshot "works as expected", ctx do
      my_fun("foo", 123, ctx)
    end
  end
  ```
  """
  @spec test_snapshot(binary(), Macro.t(), keyword()) :: Macro.t()
  defmacro test_snapshot(name, context, opts) do
    expr = Keyword.fetch!(opts, :do)

    quote do
      @tag unquote(@snapshot_test_tag)
      test unquote(name), unquote(context) do
        handle_snapshot!(unquote(expr), __ENV__)
      end
    end
  end

  ################################
  # Private API
  ################################

  defp snapshot_file!(file, function) do
    basename = snapshot_file_basename(function)
    test_paths = test_paths()

    test_paths
    |> Enum.find(&String.starts_with?(file, &1))
    |> case do
      path when is_binary(path) ->
        sub_path =
          file
          |> Path.rootname()
          |> String.trim_leading(path)

        Path.join([path, @snapshot_directory, sub_path, basename])

      _ ->
        raise RuntimeError, """
        Snapshot tests must be located in one of the project's test paths.
        """
    end
  end

  defp snapshot_file_basename(function) do
    function
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/u, "  ")
    |> String.replace(~r/[\s-]+/, "_")
    |> Kernel.<>(".snap")
  end

  defp test_paths do
    :persistent_term.get({__MODULE__, :test_paths})
  rescue
    ArgumentError ->
      paths =
        @test_paths
        |> maybe_add_default_path()
        |> Enum.map(&Path.expand/1)
        |> Enum.sort()
        |> Enum.reduce([], &maybe_add_test_path/2)

      :persistent_term.put({__MODULE__, :test_paths}, paths)
      paths
  end

  defp maybe_add_default_path([]) do
    if File.dir?("test") do
      ["test"]
    else
      []
    end
  end

  defp maybe_add_default_path(paths), do: paths

  defp maybe_add_test_path(path, []), do: [path]

  defp maybe_add_test_path(path, [last | _] = paths) do
    if String.starts_with?(path, last <> "/") do
      paths
    else
      [path | paths]
    end
  end

  defp create_snapshot!(file, value) do
    file
    |> Path.dirname()
    |> File.mkdir_p!()

    snapshot =
      value
      |> Inspect.Algebra.to_doc(@inspect_opts)
      |> Inspect.Algebra.group()
      |> Inspect.Algebra.concat(Inspect.Algebra.line())
      |> Inspect.Algebra.format(80)

    File.write!(file, snapshot)
  end

  defp compare_snapshot!(file, value) do
    {snapshot, _} = Code.eval_file(file)

    if snapshot == value do
      :ok
    else
      raise ExUnit.AssertionError,
        left: value,
        right: snapshot,
        message: "Value does not match snapshot: #{file}",
        expr: "value == snapshot"
    end
  end
end
