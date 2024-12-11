defmodule ExposureTest do
  use ExUnit.Case

  import Exposure

  setup_all do
    %{context: :new}
  end

  describe "test_snapshot/2" do
    test_snapshot "compares result to snapshot" do
      date = ~D[2023-07-15]
      time = ~T[21:00:00.000]

      %{
        date: date,
        datetime: DateTime.new!(date, time),
        float: 3.141592654,
        keyword: [a: 1, b: 2, c: 3],
        list: ["apple", "banana", "orange"],
        map: %{"key" => "value", 1 => "foo"},
        integer: 69_420,
        string: "This is a string.",
        time: time,
        tuple: {:ok, 200}
      }
    end
  end

  describe "test_snapshot/3" do
    test_snapshot "compares result to snapshot", ctx do
      %{context: :old}
      |> Map.merge(ctx)
      |> Map.take([:context, :exposure])
    end
  end

  describe "handle_snapshot!/2" do
    test "will raise an error if result doesn't match snapshot" do
      refute System.get_env("EXPOSURE_OVERRIDE", "false") == "true"

      assert_raise ExUnit.AssertionError, fn ->
        handle_snapshot!("incorrect value", __ENV__)
      end
    end

    test "will raise an error if test doesn't have a snapshot" do
      refute System.get_env("EXPOSURE_OVERRIDE", "false") == "true"

      assert_raise RuntimeError, fn ->
        handle_snapshot!("correct value", __ENV__)
      end
    end
  end
end
