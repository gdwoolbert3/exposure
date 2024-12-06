defmodule Mix.Tasks.Exposure.Clean do
  @moduledoc """
  TODO(Gordon) - Add this
  """

  use Mix.Task

  @preferred_cli_env :test
  @recursive true
  @shortdoc "Deletes unused snapshot files and recreates others"

  ################################
  # Mix.Task Callbacks
  ################################

  @doc false
  @impl Mix.Task
  @spec run([binary()]) :: term()
  def run(_) do
    Enum.each(Exposure.snapshot_paths(), &File.rm_rf!/1)
    Mix.Tasks.Exposure.Update.run([])
  end
end
