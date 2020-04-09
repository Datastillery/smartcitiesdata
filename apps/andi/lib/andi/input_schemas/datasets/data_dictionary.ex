defmodule Andi.InputSchemas.Datasets.DataDictionary do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Andi.InputSchemas.Datasets.Technical
  alias Andi.InputSchemas.StructTools

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "data_dictionary" do
    field(:name, :string)
    field(:type, :string)
    field(:itemType, :string)
    field(:selector, :string)
    field(:biased, :string)
    field(:demographic, :string)
    field(:description, :string, description: "")
    field(:masked, :string)
    field(:pii, :string)
    field(:rationale, :string)
    has_many(:subSchema, __MODULE__, foreign_key: :parent_id, on_replace: :delete)

    belongs_to(:data_dictionary, __MODULE__, type: Ecto.UUID, foreign_key: :parent_id)
    belongs_to(:technical, Technical, type: Ecto.UUID, foreign_key: :technical_id)
  end

  use Accessible

  @cast_fields [
    :id,
    :name,
    :type,
    :selector,
    :itemType,
    :biased,
    :demographic,
    :description,
    :masked,
    :pii,
    :rationale
  ]
  @required_fields [
    :name,
    :type
  ]

  def changeset(dictionary, changes) do
    changes_with_id = StructTools.ensure_id(dictionary, changes)

    dictionary
    |> cast(changes_with_id, @cast_fields, empty_values: [])
    |> cast_assoc(:subSchema, with: &__MODULE__.changeset/2)
    |> foreign_key_constraint(:technical_id)
    |> foreign_key_constraint(:parent_id)
    |> validate_required(@required_fields, message: "is required")
  end

  def changeset_with_parent_id(dictionary, changes) do
    changes_with_id = StructTools.ensure_id(dictionary, changes)

    dictionary
    |> cast(changes_with_id, [:id, :name, :type, :parent_id], empty_values: [])
    |> foreign_key_constraint(:technical_id)
    |> foreign_key_constraint(:parent_id)
    |> validate_required(@required_fields, message: "is required")
  end

  def changeset_for_draft(dictionary, changes) do
    changes_with_id = StructTools.ensure_id(dictionary, changes)

    dictionary
    |> cast(changes_with_id, @cast_fields, empty_values: [])
    |> cast_assoc(:subSchema, with: &__MODULE__.changeset_for_draft/2)
    |> foreign_key_constraint(:technical_id)
    |> foreign_key_constraint(:parent_id)
  end

  def preload(struct), do: StructTools.preload(struct, [:subSchema])
end
