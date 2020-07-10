defmodule AndiWeb.EditLiveView.DataDictionaryForm do
  @moduledoc """
  LiveComponent for editing dataset schema
  """
  use Phoenix.LiveView
  import Phoenix.HTML.Form

  alias AndiWeb.EditLiveView.DataDictionaryTree
  alias AndiWeb.EditLiveView.DataDictionaryFieldEditor
  alias AndiWeb.InputSchemas.DataDictionaryFormSchema
  alias Andi.InputSchemas.Datasets
  alias Andi.InputSchemas.Datasets.DataDictionary
  alias Andi.InputSchemas.DataDictionaryFields
  alias Andi.InputSchemas.StructTools
  alias Ecto.Changeset

  def mount(_, %{"dataset" => dataset}, socket) do
    new_changeset = DataDictionaryFormSchema.changeset_from_andi_dataset(dataset)

    {:ok, assign(socket,
        add_data_dictionary_field_visible: false,
        remove_data_dictionary_field_visible: false,
        changeset: new_changeset,
        sourceFormat: dataset.technical.sourceFormat,
        visibility: "expanded",
        new_field_initial_render: false,
        dataset: dataset,
        technical_id: dataset.technical.id
      )
      |> assign(get_default_dictionary_field(new_changeset))}
  end

  def render(assigns) do
    action =
      case assigns.visibility do
        "collapsed" -> "EDIT"
        "expanded" -> "MINIMIZE"
      end

    ~L"""
    <div id="data-dictionary-form" class="form-component">
      <div class="component-header" phx-click="toggle-component-visibility" phx-value-component="data_dictionary_form">
        <h3 class="component-number component-number--<%= @visibility %>">2</h3>
        <div class="component-title full-width">
          <h2 class="component-title-text component-title-text--<%= @visibility %> ">Data Dictionary</h2>
          <div class="component-title-action">
            <div class="component-title-action-text--<%= @visibility %>"><%= action %></div>
            <div class="component-title-icon--<%= @visibility %>"></div>
          </div>
        </div>
      </div>

      <div class="form-section">
        <%= f = form_for @changeset, "#", [phx_change: :cam, as: :form_data] %>
          <div class="component-edit-section--<%= @visibility %>">
            <div class="data-dictionary-form-edit-section form-grid">
              <div class="data-dictionary-form__tree-section">
                <div class="data-dictionary-form__tree-header data-dictionary-form-tree-header">
                  <div class="label">Enter/Edit Fields</div>
                  <div class="label label--inline">TYPE</div>
                </div>

                <div class="data-dictionary-form__tree-content data-dictionary-form-tree-content">
                  <%= live_component(@socket, DataDictionaryTree, id: :data_dictionary_tree, root_id: :data_dictionary_tree, form: @changeset |> form_for(nil), field: :schema, selected_field_id: @selected_field_id, new_field_initial_render: @new_field_initial_render) %>
                </div>

                <div class="data-dictionary-form__tree-footer data-dictionary-form-tree-footer" >
                  <div class="data-dictionary-form__add-field-button" phx-click="add_data_dictionary_field"></div>
                  <div class="data-dictionary-form__remove-field-button" phx-click="remove_data_dictionary_field"></div>
                </div>
              </div>

              <div class="data-dictionary-form__edit-section">
                <%= live_component(@socket, DataDictionaryFieldEditor, id: :data_dictionary_field_editor, form: @current_data_dictionary_item, source_format: @sourceFormat) %>
              </div>
            </div>

            <div class="edit-button-group form-grid">
              <div class="edit-button-group__cancel-btn">
                <a href="#metadata-form" id="back-button" class="btn btn--back btn--large" phx-click="toggle-component-visibility" phx-value-component-expand="metadata_form" phx-value-component-collapse="data_dictionary_form">Back</a>
                <button type="button" class="btn btn--large" phx-click="cancel-edit">Cancel</button>
              </div>

              <div class="edit-button-group__save-btn">
                <a href="#url-form" id="next-button" class="btn btn--next btn--large btn--action" phx-click="toggle-component-visibility" phx-value-component-expand="url_form" phx-value-component-collapse="data_dictionary_form">Next</a>
                <button id="save-button" name="save-button" class="btn btn--save btn--large" type="button" phx-click="camsave">Save Draft</button>
              </div>
            </div>
          </div>
        </form>
      </div>

      <%= live_component(@socket, AndiWeb.EditLiveView.DataDictionaryAddFieldEditor, id: :data_dictionary_add_field_editor, eligible_parents: get_eligible_data_dictionary_parents(@dataset), visible: @add_data_dictionary_field_visible, dataset_id: @dataset.id,  selected_field_id: @selected_field_id ) %>

      <%= live_component(@socket, AndiWeb.EditLiveView.DataDictionaryRemoveFieldEditor, id: :data_dictionary_remove_field_editor, selected_field: @current_data_dictionary_item, visible: @remove_data_dictionary_field_visible) %>
    </div>
    """
  end

  def handle_event("cam", %{"data_dictionary_form_schema" => form_schema}, socket) do
    form_schema
    |> DataDictionaryFormSchema.changeset_from_form_data()
    |> complete_validation(socket)
    |> mark_changes()
  end

  def handle_event("camsave", _, socket) do
    changeset =
      socket.assigns.changeset
      |> Map.put(:action, :update)

    send(socket.parent_pid, {:form_save, changeset})

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("toggle-component-visibility", %{"component" => component}, socket) do
    new_visibility = case socket.assigns.visibility do
                       "expanded" -> "collapsed"
                       "collapsed" -> "expanded"
                     end

    {:noreply, assign(socket, visibility: new_visibility)}
  end

  def handle_event("add_data_dictionary_field", _, socket) do
    changes = Ecto.Changeset.apply_changes(socket.assigns.changeset) |> StructTools.to_map
    {:ok, andi_dataset} = Datasets.update_from_form(socket.assigns.dataset.id, changes)
    changeset = DataDictionaryFormSchema.changeset_from_andi_dataset(andi_dataset)

    {:noreply, assign(socket, changeset: changeset, add_data_dictionary_field_visible: true)}
  end

  def handle_event("remove_data_dictionary_field", _, socket) do
    should_show_remove_field_modal = socket.assigns.selected_field_id != :no_dictionary

    {:noreply, assign(socket, remove_data_dictionary_field_visible: should_show_remove_field_modal)}
  end

  def handle_info({:add_data_dictionary_field_succeeded, field_id}, socket) do
    dataset = Datasets.get(socket.assigns.dataset.id)
    changeset = DataDictionaryFormSchema.changeset_from_andi_dataset(dataset)

    {:noreply,
     assign(socket,
       changeset: changeset,
       selected_field_id: field_id,
       add_data_dictionary_field_visible: false,
       new_field_initial_render: true
     )}
  end

  def handle_info({:remove_data_dictionary_field_succeeded, deleted_field_parent_id, deleted_field_index}, socket) do
    new_selected_field =
      socket.assigns.changeset
      |> get_new_selected_field(deleted_field_parent_id, deleted_field_index, socket.assigns.technical_id)

    new_selected_field_id =
      case new_selected_field do
        :no_dictionary ->
          :no_dictionary

        new_selected ->
          Changeset.fetch_field!(new_selected, :id)
      end

    dataset = Datasets.get(socket.assigns.dataset.id)
    changeset = DataDictionaryFormSchema.changeset_from_andi_dataset(dataset)

    {:noreply,
     assign(socket,
       changeset: changeset,
       selected_field_id: new_selected_field_id,
       new_field_initial_render: true,
       remove_data_dictionary_field_visible: false
     )}
  end

  def handle_info({:add_data_dictionary_field_cancelled}, socket) do
    {:noreply, assign(socket, add_data_dictionary_field_visible: false)}
  end

  def handle_info({:remove_data_dictionary_field_cancelled}, socket) do
    {:noreply, assign(socket, remove_data_dictionary_field_visible: false)}
  end

  def handle_info({:assign_editable_dictionary_field, :no_dictionary, _, _, _}, socket) do
    current_data_dictionary_item = DataDictionary.changeset_for_draft(%DataDictionary{}, %{}) |> form_for(nil)

    {:noreply, assign(socket, current_data_dictionary_item: current_data_dictionary_item, selected_field_id: :no_dictionary)}
  end

  def handle_info({:assign_editable_dictionary_field, field_id, index, name, id}, socket) do
    new_form = find_field_in_changeset(socket.assigns.changeset, field_id) |> form_for(nil)
    field = %{new_form | index: index, name: name, id: id}

    {:noreply, assign(socket, current_data_dictionary_item: field, selected_field_id: field_id)}
  end

  defp get_new_selected_field(changeset, parent_id, deleted_field_index, technical_id) do
    if parent_id == technical_id do
      changeset
      |> Changeset.fetch_change!(:schema)
      |> get_next_sibling(deleted_field_index)
    else
      changeset
      |> find_field_in_changeset(parent_id)
      |> Changeset.get_change(:subSchema, [])
      |> get_next_sibling(deleted_field_index)
    end
  end

  defp get_next_sibling(parent_schema, _) when length(parent_schema) <= 1, do: :no_dictionary

  defp get_next_sibling(parent_schema, deleted_field_index) when deleted_field_index == 0 do
    Enum.at(parent_schema, deleted_field_index + 1)
  end

  defp get_next_sibling(parent_schema, deleted_field_index) do
    Enum.at(parent_schema, deleted_field_index - 1)
  end

  defp complete_validation(changeset, socket) do
    new_changeset = Map.put(changeset, :action, :update)
    current_form = socket.assigns.current_data_dictionary_item

    updated_current_field =
      case current_form do
        :no_dictionary ->
          :no_dictionary

        _ ->
          new_form_template = find_field_in_changeset(new_changeset, current_form.source.changes.id) |> form_for(nil)
          %{current_form | source: new_form_template.source, params: new_form_template.params}
      end

    {:noreply, assign(socket, changeset: new_changeset, current_data_dictionary_item: updated_current_field)}
  end

  defp find_field_in_changeset(changeset, field_id) do
    changeset
    |> Changeset.get_change(:schema, [])
    |> find_field_changeset_in_schema(field_id)
    |> handle_field_not_found()
  end

  defp find_field_changeset_in_schema(schema, field_id) do
    Enum.reduce_while(schema, nil, fn field, _ ->
      if Changeset.get_field(field, :id) == field_id do
        {:halt, field}
      else
        case find_field_changeset_in_schema(Changeset.get_change(field, :subSchema, []), field_id) do
          nil -> {:cont, nil}
          value -> {:halt, value}
        end
      end
    end)
  end

  defp handle_field_not_found(nil), do: DataDictionary.changeset_for_new_field(%DataDictionary{}, %{})
  defp handle_field_not_found(found_field), do: found_field

  defp get_default_dictionary_field(%{changes: %{schema: schema}} = changeset) when schema != [] do
    first_data_dictionary_item =
      form_for(changeset, "#", as: :form_data)
      |> inputs_for(:schema)
      |> hd()

    first_selected_field_id = input_value(first_data_dictionary_item, :id)

    #TODO ask jake about this
    # [
    #   current_data_dictionary_item: first_data_dictionary_item,
    #   selected_field_id: first_selected_field_id
    # ]

    [
      current_data_dictionary_item: :no_dictionary,
      selected_field_id: :no_dictionary
    ]
  end

  defp get_default_dictionary_field(_changeset) do
    [
      current_data_dictionary_item: :no_dictionary,
      selected_field_id: :no_dictionary
    ]
  end

  defp get_eligible_data_dictionary_parents(dataset) do
    DataDictionaryFields.get_parent_ids(dataset)
  end

  defp mark_changes({:noreply, socket}) do
    {:noreply, assign(socket, unsaved_changes: true)}
  end
end
