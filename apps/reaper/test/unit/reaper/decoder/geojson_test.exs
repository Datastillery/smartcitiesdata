defmodule Reaper.Decoder.GeoJsonTest do
  use ExUnit.Case
  import Checkov

  alias SmartCity.TestDataGenerator, as: TDG

  @filename "#{__MODULE__}_temp_file"

  setup do
    on_exit(fn ->
      File.rm(@filename)
    end)

    :ok
  end

  describe "decode/2" do
    test "should return a list of feature maps when sourceFormat is geojson" do
      data = %{
        name: "cool dataset",
        features: [
          %{"geometry" => "data"},
          %{"geometry" => "more data"}
        ]
      }

      structure =
        data
        |> Jason.encode!()

      dataset = TDG.create_dataset(id: "ds1", technical: %{sourceFormat: "geojson"})

      File.write!(@filename, structure)

      {:ok, response} = Reaper.Decoder.GeoJson.decode({:file, @filename}, dataset)

      assert %{"feature" => Enum.at(data.features, 0)} == Enum.at(response, 0)
      assert %{"feature" => Enum.at(data.features, 1)} == Enum.at(response, 1)
      assert 2 == Enum.count(response)
    end

    test "should return a list of feature maps when sourceFormat is zip" do
      data = %{
        name: "cool dataset",
        features: [
          %{"geometry" => "data"},
          %{"geometry" => "more data"}
        ]
      }

      structure =
        data
        |> Jason.encode!()

      dataset = TDG.create_dataset(id: "ds1", technical: %{sourceFormat: "zip"})

      File.write!(@filename, structure)

      {:ok, response} = Reaper.Decoder.GeoJson.decode({:file, @filename}, dataset)

      assert %{"feature" => Enum.at(data.features, 0)} == Enum.at(response, 0)
      assert %{"feature" => Enum.at(data.features, 1)} == Enum.at(response, 1)
      assert 2 == Enum.count(response)
    end

    data_test "throws error when given #{geojson_input} when sourceFormat is geojson" do
      File.write!(@filename, geojson_input)
      dataset = TDG.create_dataset(id: "ds1", technical: %{sourceFormat: "geojson"})
      response = Reaper.Decoder.GeoJson.decode({:file, @filename}, dataset)
      assert {:error, geojson_input, expected_error_message} == response

      where([
        [:geojson_input, :expected_error_message],
        ["{}", "Could not parse GeoJSON"],
        [~s|{"features": {}}|, "Could not parse GeoJSON"],
        ["invalid json", %Jason.DecodeError{data: "invalid json", position: 0, token: nil}],
        ["true", "Could not parse GeoJSON"]
      ])
    end

    data_test "throws error when given #{geojson_input} when sourceFormat is zip" do
      File.write!(@filename, geojson_input)
      dataset = TDG.create_dataset(id: "ds1", technical: %{sourceFormat: "zip"})
      response = Reaper.Decoder.GeoJson.decode({:file, @filename}, dataset)
      assert {:error, geojson_input, expected_error_message} == response

      where([
        [:geojson_input, :expected_error_message],
        ["{}", "Could not parse GeoJSON"],
        [~s|{"features": {}}|, "Could not parse GeoJSON"],
        ["invalid json", %Jason.DecodeError{data: "invalid json", position: 0, token: nil}],
        ["true", "Could not parse GeoJSON"]
      ])
    end
  end

  describe "handle/1" do
    data_test "source_format of '#{format}' returns #{result}" do
      assert result == Reaper.Decoder.GeoJson.handle?(format)

      where([
        [:format, :result],
        ["application/geo+json", true],
        ["application/zip", true],
        ["geojson", false],
        ["json", false],
        ["csv", false],
        ["", false],
        [nil, false]
      ])
    end
  end
end
