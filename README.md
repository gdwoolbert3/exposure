# Exposure

TODO(Gordon) - Add badges

`Exposure` is a simple and leightweight snapshot testing library for Elixir

## Installation

This package can be installed by adding `:exposure` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:exposure, "~> 0.1.0"}
  ]
end
```

TODO(Gordon) - test env only?

## Documentation

TODO(Gordon) - Add this

## Usage

`Exposure` is easy to use and is designed to integrate seamlessly with Elixir's
`ExUnit` module.

### Defining Snapshot Tests

Snapshot tests can be defined with the `test_snapshot` macro. This macro is
syntactically similar to the normal `test` macro and interacts with other
`ExUnit` entities in the same way.

```elixir
defmodule SampleTest do
  use ExUnit.Case

  import Exposure

  setup_all do
    %{foo: 1, bar: 2}
  end

  describe "Map.put/3" do
    @tag :sample_tag
    test_snapshot "will add a new pair to a map", ctx do
      ctx
      |> Map.put(:baz, 3)
      |> Map.take([:foo, :bar, :baz])
    end
  end
end
```

### Updating Snapshot Files

Once a snapshot test is defined, a snapshot file can be generated with the
following mix task:

```bash
mix exposure.generate
```

`Exposure` creates a snapshot directory for each test path and a snapshot file
for each test. The snapshot directory structure mirrors the test path directory
structure. For the example snapshot test above, the command would generate a
file at the following location:

```
test/_snapshots/sample_test/test_map_put_3_will_add_a_new_pair_to_a_map.exs
```

By default, this task will generate the snapshot files for **all** snapshot
tests but `mix test` filter arguments can be included to only generate specific
snapshot files:

```bash
# Using the test location as a filter
mix exposure.generate test/sample_test.exs:12

# Using tags as a filter
mix exposure.generate --only sample_tag
```

This works because `mix exposure.generate` uses `mix test` under the hood. In
fact, `mix exposure.generate ...` is equivalent to the following:

```bash
EXPOSURE_OVERRIDE=true mix test --only exposure ...
```

### Running Snapshot Tests

Once a snapshot file has been created, a snapshot test can be run in the same
way as a normal test:

```bash
mix test test/sample_test.exs:12
```

### Cleaning Snapshot Files

`Exposure` also includes a mix task for snapshot file cleanup:

```bash
mix exposure.clean
```

This task regenerates all snapshot files and deletes any that are unused.

### Configuration

`Exposure` has a few few configuration options that can be set in the
application config:

```elixir
# In config/test.exs
config :exposure,
  snapshot_directory: "my_snapshot_dir",
  snapshot_test_tag: :my_test_tag
```

More specifically, the configuration options are:

* `:snapshot_directory` - A `t:binary/0` denoting the name of the snapshot
  directory. Defaults to `_snapshots`.

* `:snapshot_test_tag` - An `t:atom/0` denoting the tag that `Exposure` uses
  under the hood to identify snapshot tests. Defaults to `:exposure`.

### Test Paths

`Exposure` can also be used for projects with non-traditional test paths. For
more information on how to configure multiple test paths, see the `mix test`
[docs](https://hexdocs.pm/mix/1.12/Mix.Tasks.Test.html#module-configuration).

In general, `Exposure` creates a separate snapshot directory for each test path.
The only exception is if one test path contains another. In that case, a
snapshot directory is only created in the parent path. For example, consider a
project with the following configuration:

```elixir
# In mix.exs
def project do
  [
    test_paths: ["test", "other_test", "other_test/dir"]
  ]
end
```

`Exposure` would only create two snapshot directories for the above project:

```
test/_snapshots
other_test/_snapshots
```

`Exposure` requires that all snapshot tests exist within one of the project test
paths. In conjunction with the above simplification, this constraint guarantees
a consistent snapshot file location for every test.

## Other Libraries

The `Exposure` API is heavily inspired by the
[`Snapshy`](https://github.com/DCzajkowski/snapshy) library. For the vast
majority of cases, `Snapshy` is more than sufficient. The main differences are
relatively niche:

* `Exposure` has explicit support for additional test paths.

* `Exposure` has slightly different naming rules for snapshot files.

* `Exposure` includes custom mix tasks for convenience.

* `Exposure` requires a snapshot to exist before running a test.

If those differences are unimportant for your project, `Snapshy` may be a better
choice.

Additionally, no discussion of snapshot testing in Elixir would be complete
without mentioning the
[`assert_value`](https://github.com/assert-value/assert_value_elixir) package.
The concept of a snapshot is handled slightly differently in `assert_value` but
the library is robust and mature and definitely worth investigating.
