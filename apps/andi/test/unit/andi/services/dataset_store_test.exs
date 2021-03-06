defmodule Andi.Services.DatasetStoreTest do
  use ExUnit.Case
  use Placebo

  alias SmartCity.TestDataGenerator, as: TDG
  alias Andi.Services.DatasetStore

  describe "get_all/0" do
    test "retrieves all events from Brook" do
      dataset1 = TDG.create_dataset(%{})
      dataset2 = TDG.create_dataset(%{})
      expected_datasets = {:ok, [dataset1, dataset2]}
      allow(DatasetStore.get_all(), return: expected_datasets)
      assert expected_datasets == DatasetStore.get_all()
    end

    test "returns an error when brook returns an error" do
      expected_error = {:error, "bad things"}
      allow(DatasetStore.get_all(), return: expected_error)
      assert expected_error == DatasetStore.get_all()
    end
  end

  describe "get_all!/0" do
    test "raises the error returned by brook" do
      expected_error = "bad things"
      allow(DatasetStore.get_all!(), return: expected_error)
      assert expected_error == DatasetStore.get_all!()
    end
  end
end
