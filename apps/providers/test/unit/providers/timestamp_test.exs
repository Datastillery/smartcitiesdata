defmodule Providers.TimestampTest do
  use ExUnit.Case

  describe "v1" do
    test "provides a valid iso8601 timestamp" do
      timestamp = Providers.Timestamp.provide("1", %{})

      assert {:ok, _timestamp} = NaiveDateTime.from_iso8601(timestamp)
    end
  end

end
