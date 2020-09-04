defmodule Andi.InputSchemas.Datasets.Dataset do
  @moduledoc """
  Module for validating Ecto.Changesets on flattened dataset input.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Andi.InputSchemas.Datasets
  alias Andi.InputSchemas.Datasets.Business
  alias Andi.InputSchemas.Datasets.Technical
  alias Andi.InputSchemas.Datasets.DataDictionary
  alias Andi.InputSchemas.StructTools

  @primary_key {:id, :string, autogenerate: false}
  schema "datasets" do
    field(:dlq_message, :map)
    field(:ingestedTime, :utc_datetime, default: nil)
    field(:version, :string)
    has_many(:data_dictionaries, DataDictionary)
    has_one(:business, Business, on_replace: :update)
    has_one(:technical, Technical, on_replace: :update)
  end

  use Accessible

  @cast_fields [:id, :ingestedTime, :version, :dlq_message]

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(dataset, changes) do
    dataset
    |> Andi.Repo.preload([:business, :technical])
    |> cast(changes, @cast_fields)
    |> cast_assoc(:technical, with: &Technical.changeset/2)
    |> cast_assoc(:business, with: &Business.changeset/2)
  end

  def changeset_for_draft(dataset, changes) do
    dataset
    |> Andi.Repo.preload([:business, :technical])
    |> cast(changes, @cast_fields)
    |> cast_assoc(:technical, with: &Technical.changeset_for_draft/2)
    |> cast_assoc(:business, with: &Business.changeset_for_draft/2)
  end

  def preload(struct), do: StructTools.preload(struct, [:technical, :business])

  def full_validation_changeset(changes), do: full_validation_changeset(%__MODULE__{}, changes)

  def full_validation_changeset(schema, changes) do
    changeset(schema, changes)
    |> validate_unique_system_name()
  end

  def validate_unique_system_name(%{changes: %{technical: technical}} = changeset) do
    id = Ecto.Changeset.get_field(changeset, :id)
    data_name = Ecto.Changeset.get_change(technical, :dataName)
    org_name = Ecto.Changeset.get_change(technical, :orgName)

    technical_changeset = check_uniqueness(technical, id, data_name, org_name)
    Ecto.Changeset.put_change(changeset, :technical, technical_changeset)
  end

  def validate_unique_system_name(changeset) do
    id = Ecto.Changeset.get_field(changeset, :datasetId)
    data_name = Ecto.Changeset.get_change(changeset, :dataName)
    org_name = Ecto.Changeset.get_change(changeset, :orgName)

    check_uniqueness(changeset, id, data_name, org_name)
  end

  defp check_uniqueness(changeset, id, data_name, org_name) do
    case Datasets.is_unique?(id, data_name, org_name) do
      false ->
        add_data_name_error(changeset)

      _ ->
        changeset
    end
  end

  defp add_data_name_error(nil), do: nil

  defp add_data_name_error(changeset) do
    changeset
    |> clear_data_name_errors()
    |> add_error(:dataName, "existing dataset has the same orgName and dataName")
  end

  defp clear_data_name_errors(technical_changeset) do
    cleared_errors =
      technical_changeset.errors
      |> Keyword.drop([:dataName])

    Map.put(technical_changeset, :errors, cleared_errors)
  end
end
