defmodule Mix.Tasks.Exposure.Generate do
  @shortdoc "Generates snapshot files"

  @moduledoc """
  Generates the snapshot files for a project.

  By default, this task generates snapshot files for **all** snapshot tests but
  `mix test` filter arguments can be included to only generate specific snapshot
  files.

  ## Examples

  ```
  # Generates snapshot files for all snapshot tests
  mix exposure.generate

  # Generates a snapshot file for a specific test
  mix exposure.generate test/sample_test.exs:12

  # Generates snapshot files for all tests tagged with "sample_tag"
  mix exposure.generate --only sample_tag
  ```
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
  def run(args) do
    tag = Exposure.snapshot_test_tag()
    args = ["--only", to_string(tag)] ++ args
    System.put_env(%{"EXPOSURE_OVERRIDE" => "true", "MIX_ENV" => "test"})
    Mix.Tasks.Test.run(args)
  end
end
