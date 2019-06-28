defmodule Forklift.Messages.Statement do
  @moduledoc """
  Builds Presto statements from data and schema
  """
  require Logger

  @doc """
  Builds Presto statements from data and schema
  """
  def build(schema, data) do
    columns = schema.columns

    columns_fragment =
      columns
      |> Enum.map(&Map.get(&1, :name))
      |> Enum.map(&to_string/1)
      |> Enum.map(&~s("#{&1}"))
      |> Enum.join(",")

    data_fragment =
      data
      |> Enum.map(fn datum -> Forklift.Messages.SchemaFiller.fill(columns, datum) end)
      |> Enum.map(&format_columns(columns, &1))
      |> Enum.map(&to_row_string/1)
      |> Enum.join(",")

    ~s/insert into "#{schema.system_name}" (#{columns_fragment}) values #{data_fragment}/
  rescue
    e ->
      Logger.error("Unhandled Statement Builder error: #{inspect(e)}")
      {:error, inspect(e)}
  end

  defp format_columns(columns, row) do
    Enum.map(columns, fn %{name: name} = column ->
      row
      |> Map.get(String.to_atom(name))
      |> format_data(column)
    end)
  end

  defp format_data(nil, %{type: _}), do: "null"

  defp format_data("", %{type: "string"}), do: ~S|''|

  defp format_data("", %{type: _}), do: "null"

  defp format_data(value, %{type: "string"}) do
    value
    |> to_string()
    |> escape_quote()
    |> (&~s('#{&1}')).()
  end

  defp format_data(value, %{type: "date"}), do: ~s|DATE '#{value}'|

  defp format_data(value, %{type: "timestamp"}) do
    date_format =
      cond do
        String.length(value) == 19 -> ~s|'%Y-%m-%dT%H:%i:%S'|
        String.length(value) == 20 -> ~s|'%Y-%m-%dT%H:%i:%SZ'|
        String.ends_with?(value, "Z") -> ~s|'%Y-%m-%dT%H:%i:%S.%fZ'|
        true -> ~s|'%Y-%m-%dT%H:%i:%S.%f'|
      end

    ~s|date_parse('#{value}', #{date_format})|
  end

  defp format_data(value, %{type: "time"}), do: ~s|'#{value}'|

  defp format_data(value, %{type: "integer"}) when is_binary(value) do
    value
    |> Integer.parse()
    |> elem(0)
  end

  defp format_data(value, %{type: "float"}) when is_binary(value) do
    value
    |> Float.parse()
    |> elem(0)
  end

  defp format_data(value, %{type: "map", subSchema: sub_schema}) do
    sub_schema
    |> format_columns(value)
    |> to_row_string()
  end

  defp format_data(values, %{type: "list", itemType: "map", subSchema: sub_schema}) do
    values
    |> Enum.map(fn value -> format_data(value, %{type: "map", subSchema: sub_schema}) end)
    |> to_array_string()
  end

  defp format_data(values, %{type: "list", itemType: item_type}) do
    values
    |> Enum.map(fn value -> format_data(value, %{type: item_type}) end)
    |> to_array_string()
  end

  defp format_data(value, _type) do
    value
  end

  defp to_row_string(values) do
    values
    |> Enum.join(",")
    |> (&~s|row(#{&1})|).()
  end

  defp to_array_string(values) do
    values
    |> Enum.join(",")
    |> (&~s|array[#{&1}]|).()
  end

  defp escape_quote(value), do: String.replace(value, "'", "''")
end
