defmodule Mix.Tasks.Exposure.Clean do
  @shortdoc "Regenerates snapshot files and removes unused"

  @moduledoc """
  Regenerates snapshot files for all snapshot tests and removes unused snapshot
  files.
  """

  use Mix.Task

  @preferred_cli_env :test
  @recursive true

  ################################
  # Mix.Task Callbacks
  ################################

  @doc false
  @impl Mix.Task
  @spec run([binary()]) :: term()
  def run(_) do
    Enum.each(Exposure.snapshot_paths(), &File.rm_rf!/1)
    Mix.Tasks.Exposure.Generate.run([])
  end
end
