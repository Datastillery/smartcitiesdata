defmodule AndiWeb.InputSchemas.DataDictionaryFormSchema do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Andi.InputSchemas.StructTools
  alias Andi.InputSchemas.Datasets.DataDictionary
  alias Andi.InputSchemas.DatasetSchemaValidator
  alias SmartCity.SchemaGenerator

  schema "data_dictionary" do
    has_many(:schema, DataDictionary, on_replace: :delete)
  end

  use Accessible

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(dictionary, changes) do
    source_format = Map.get(changes, :sourceFormat, nil)
    changes_with_id = StructTools.ensure_id(dictionary, changes)

    dictionary
    |> cast(changes_with_id, [], empty_values: [])
    |> cast_assoc(:schema, with: &DataDictionary.changeset(&1, &2, source_format), invalid_message: "is required")
    |> validate_required(:schema, message: "is required")
    |> validate_schema()
  end

  def changeset_from_andi_dataset(dataset) do
    dataset = StructTools.to_map(dataset)
    technical_changes = dataset.technical

    changeset(technical_changes)
  end

  def changeset_from_form_data(form_data) do
    form_data
    |> AtomicMap.convert(safe: false, underscore: false)
    |> changeset()
  end

  def changeset_from_file(parsed_file, dataset_id) do
    generated_schema = generate_schema(parsed_file, dataset_id)

    changeset_from_form_data(%{schema: generated_schema})
  end

  def generate_schema(decoded_file, dataset_id) do
    decoded_file
    |> SchemaGenerator.generate_schema()
    |> Enum.map(&assign_schema_field_details(&1, dataset_id, nil))
  end

  defp assign_schema_field_details(schema_field, dataset_id, parent_bread_crumb) do
    bread_crumb =
      case parent_bread_crumb do
        nil -> Map.get(schema_field, "name")
        parent_bread_crumb -> parent_bread_crumb <> " > " <> Map.get(schema_field, "name")
      end

    updated_field =
      schema_field
      |> Map.put("dataset_id", dataset_id)
      |> Map.put("bread_crumb", bread_crumb)

    case Map.has_key?(schema_field, "subSchema") do
      true ->
        updated_sub_schema =
          Enum.map(Map.get(schema_field, "subSchema"), fn child_field ->
            assign_schema_field_details(child_field, dataset_id, bread_crumb)
          end)

        Map.put(updated_field, "subSchema", updated_sub_schema)

      false ->
        updated_field
    end
  end

  defp validate_schema(%{changes: %{sourceType: source_type}} = changeset)
       when source_type in ["ingest", "stream"] do
    case Ecto.Changeset.get_field(changeset, :schema, nil) do
      [] -> add_error(changeset, :schema, "cannot be empty")
      nil -> add_error(changeset, :schema, "is required", validation: :required)
      _ -> validate_schema_internals(changeset)
    end
  end

  defp validate_schema(changeset), do: changeset

  defp validate_schema_internals(%{changes: changes} = changeset) do
    schema =
      Ecto.Changeset.get_field(changeset, :schema, [])
      |> StructTools.to_map()

    DatasetSchemaValidator.validate(schema, changes[:sourceFormat])
    |> Enum.reduce(changeset, fn error, changeset_acc -> add_error(changeset_acc, :schema, error) end)
  end
end
