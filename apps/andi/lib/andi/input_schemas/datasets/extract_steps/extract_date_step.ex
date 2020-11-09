defmodule Andi.InputSchemas.Datasets.ExtractDateStep do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Timex.Format.DateTime.Formatter
  alias Andi.InputSchemas.Datasets.Technical
  alias Andi.InputSchemas.StructTools

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  embedded_schema do
    field(:destination, :string)
    field(:deltaTimeUnit, :string)
    field(:deltaTimeValue, :integer)
    field(:format, :string)
  end

  use Accessible

  @cast_fields [:id, :format, :deltaTimeValue, :deltaTimeUnit, :destination]
  @required_fields [:format, :destination]

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(extract_step, changes) do
    changes_with_id = StructTools.ensure_id(extract_step, changes) |> scrub_time_value()

    extract_step
    |> cast(changes_with_id, @cast_fields, empty_values: [])
    |> validate_required(@required_fields, message: "is required")
    |> validate_time_unit()
    |> validate_format()
  end

  def changeset_for_draft(extract_step, changes) do
    changes_with_id = StructTools.ensure_id(extract_step, changes) |> scrub_time_value()

    extract_step
    |> cast(changes_with_id, @cast_fields, empty_values: [])
  end

  def changeset_from_form_data(form_data) do
    form_data_as_params = AtomicMap.convert(form_data, safe: false, underscore: false)

    changeset(form_data_as_params)
  end

  def changeset_from_andi_step(nil), do: changeset(%{})

  def changeset_from_andi_step(dataset_date_step) do
    dataset_date_step
    |> StructTools.to_map()
    |> changeset()
  end

  def preload(struct), do: struct

  defp scrub_time_value(%{deltaTimeValue: ""} = changes), do: Map.put(changes, :deltaTimeValue, nil)
  defp scrub_time_value(changes), do: changes

  defp validate_format(%{changes: %{format: format}} = changeset) do
    case Formatter.validate(format) do
      :ok ->
        changeset

      {:error, %RuntimeError{message: error_msg}} ->
        add_error(changeset, :format, error_msg)

      {:error, err} ->
        add_error(changeset, :format, err)
    end
  end

  defp validate_format(changeset) do
    put_change(changeset, :format, "{YYYY}-{0M}-{0D} {h24}:{m}:{s}")
  end

  defp validate_time_unit(%{changes: %{deltaTimeUnit: unit}} = changeset)
       when unit in ["microseconds", "milliseconds", "seconds", "minutes", "hours", "days", "weeks", "months", "years", ""],
       do: changeset

  defp validate_time_unit(%{changes: %{deltaTimeUnit: unit}} = changeset), do: add_error(changeset, :deltaTimeUnit, "invalid time unit")

  defp validate_time_unit(changeset), do: changeset

  defp clear_field_errors(changset, field) do
    Map.update(changset, :errors, [], fn errors -> Keyword.delete(errors, field) end)
  end
end
