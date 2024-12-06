defmodule Mix.Tasks.Exposure.Update do
  @moduledoc """
  TODO(Gordon) - Add this
  """

  use Mix.Task

  @preferred_cli_env :test
  @recursive true
  @shortdoc "Creates or updates snapshot files"

  ################################
  # Mix.Task Callbacks
  ################################

  @doc false
  @impl Mix.Task
  @spec run([binary()]) :: term()
  def run(args) do
    tag = Exposure.snapshot_test_tag()
    args = ["--only", to_string(tag)] ++ args
    System.put_env(%{"EXPOSURE_OVERRIDE" => "true", "MIX_ENV" => "test"})
    Mix.Tasks.Test.run(args)
  end
end
