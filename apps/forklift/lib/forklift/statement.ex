defmodule Forklift.Statement do
  @moduledoc false
  require Logger

  def build(schema, data) do
    columns_fragment =
      schema.columns
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(&to_string/1)
      |> Enum.map(&("\"" <> &1 <> "\""))
      |> Enum.join(",")

    data_fragment =
      data
      |> Enum.map(&format_columns(schema.columns, &1))
      |> Enum.map(&~s/(#{Enum.join(&1, ",")})/)
      |> Enum.join(",")

    ~s/insert into "#{schema.id}" (#{columns_fragment}) values #{data_fragment}/
  rescue
    e -> Logger.error("Unhandled Statement Builder error: #{e}")
  end

  defp format_columns(columns, row) do
    Enum.map(columns, fn {name, type} ->
      row
      |> Map.get(name)
      |> format_data(type)
    end)
  end

  defp format_data(value, "string") do
    value
    |> String.replace("'", "''")
    |> (&~s/'#{&1}'/).()
  end

  defp format_data(value, _type) do
    value
  end
end
