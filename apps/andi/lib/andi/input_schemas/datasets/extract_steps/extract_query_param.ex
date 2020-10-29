defmodule Andi.InputSchemas.Datasets.ExtractQueryParam do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Andi.InputSchemas.StructTools
  alias Andi.InputSchemas.Datasets.ExtractHttpStep

  embedded_schema do
    field(:key, :string)
    field(:value, :string)
  end

  use Accessible

  @cast_fields [:key, :value]
  @required_fields [:key]

  def changeset(changes), do: changeset(%__MODULE__{}, changes)

  def changeset(query_param, changes) do
    common_changeset_operations(query_param, changes)
    |> validate_required(@required_fields, message: "is required")
  end

  def changeset_for_draft(query_param, changes) do
    common_changeset_operations(query_param, changes)
  end

  defp common_changeset_operations(query_param, changes) do
    changes_with_id = StructTools.ensure_id(query_param, changes)

    query_param
    |> cast(changes_with_id, @cast_fields, empty_values: [])
  end

  def preload(struct), do: struct
end
