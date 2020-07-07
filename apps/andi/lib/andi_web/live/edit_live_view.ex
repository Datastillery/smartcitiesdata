defmodule AndiWeb.EditLiveView do
  use AndiWeb, :live_view

  alias Andi.InputSchemas.Datasets
  alias Andi.InputSchemas.Datasets.DataDictionary
  alias Andi.InputSchemas.DataDictionaryFields
  alias Andi.InputSchemas.InputConverter
  alias Andi.InputSchemas.FormTools
  alias Andi.InputSchemas.Datasets.Dataset
  alias Andi.InputSchemas.Datasets.Technical
  alias Andi.InputSchemas.Datasets.Business
  alias Ecto.Changeset

  alias AndiWeb.EditLiveView.FinalizeForm

  import Andi
  import SmartCity.Event, only: [dataset_update: 0]
  require Logger

  def render(assigns) do
    dataset_id = assigns.dataset.id

    ~L"""
    <div class="edit-page" id="dataset-edit-page">
      <%= f = form_for @changeset, "#", [phx_change: :validate, phx_submit: :save, as: :form_data, phx_hook: "Unload", data: [show_unsaved_changes_modal: @show_unsaved_changes_modal]] %>
        <% [business] = inputs_for(f, :business) %>
        <% [technical] = inputs_for(f, :technical) %>
        <%= hidden_input(f, :id) %>
        <%= hidden_input(business, :id) %>
        <%= hidden_input(business, :orgTitle) %>
        <%= hidden_input(technical, :id) %>
        <%= hidden_input(technical, :orgId) %>
        <%= hidden_input(technical, :orgName) %>
        <%= hidden_input(technical, :dataName) %>
        <%= hidden_input(technical, :systemName) %>
        <%= hidden_input(technical, :sourceType) %>
        <%= hidden_input(technical, :sourceFormat) %>


        <div class="metadata-form-component">
          <%= live_render(@socket, AndiWeb.EditLiveView.MetadataForm, id: :metadata_form_editor, session: %{"dataset" => @dataset}) %>
        </div>

        <div class="data-dictionary-form-component">
          <%= live_render(@socket, AndiWeb.EditLiveView.DataDictionaryForm, id: :data_dictionary_form_editor, session: %{"dataset" => @dataset}) %>
        </div>


        <div class="url-form-component">
          <%= live_render(@socket, AndiWeb.EditLiveView.UrlForm, id: :url_form_editor, session: %{"dataset" => @dataset}) %>
        </div>

        <div class="finalize-form-component ">
          <%= live_render(@socket, AndiWeb.EditLiveView.FinalizeForm, id: :finalize_form_editor, session: %{"dataset" => @dataset}) %>
        </div>

      </form>

      <%= live_component(@socket, AndiWeb.EditLiveView.UnsavedChangesModal, show_unsaved_changes_modal: @show_unsaved_changes_modal) %>

      <%= if @save_success do %>
        <div id="snackbar" class="success-message"><%= @success_message %></div>
      <% end %>

      <%= if @has_validation_errors do %>
        <div id="snackbar" class="error-message">There were errors with the dataset you tried to submit.</div>
      <% end %>

      <%= if @page_error do %>
        <div id="snackbar" class="error-message">A page error occurred</div>
      <% end %>
    </div>
    """
  end

  def mount(_params, %{"dataset" => dataset}, socket) do
    new_changeset = InputConverter.andi_dataset_to_full_ui_changeset(dataset)

    Process.flag(:trap_exit, true)

    {:ok,
     assign(socket,
       changeset: new_changeset,
       dataset: dataset,
       has_validation_errors: false,
       new_field_initial_render: false,
       page_error: false,
       save_success: false,
       success_message: "",
       test_results: nil,
       testing: false,
       finalize_form_data: nil,
       unsaved_changes: false,
       show_unsaved_changes_modal: false
     )}
  end


  def handle_event("validate", %{"form_data" => form_data}, socket) do
    IO.inspect("we in here?")
    form_data
    |> InputConverter.form_data_to_ui_changeset()
    |> complete_validation(socket)
    |> mark_changes()
  end

  def handle_event("publish", _, socket) do
    socket = reset_save_success(socket)
    changeset = socket.assigns.changeset

    if changeset.valid? do
      pending_dataset = Ecto.Changeset.apply_changes(changeset)
      {:ok, andi_dataset} = Datasets.update(pending_dataset)
      {:ok, smrt_dataset} = InputConverter.andi_dataset_to_smrt_dataset(andi_dataset)
      changeset = InputConverter.andi_dataset_to_full_ui_changeset(andi_dataset)

      case Brook.Event.send(instance_name(), dataset_update(), :andi, smrt_dataset) do
        :ok ->
          {:noreply,
           assign(socket,
             dataset: andi_dataset,
             changeset: changeset,
             save_success: true,
             success_message: "Published successfully",
             page_error: false
           )}

        error ->
          Logger.warn("Unable to create new SmartCity.Dataset: #{inspect(error)}")

          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: %{changeset | action: :save}, has_validation_errors: true)}
    end
  end

  def handle_event("save", %{"form_data" => form_data, "finalize_form_data" => finalize_form_data}, socket) do
    socket = assign(socket, :finalize_form_data, finalize_form_data)

    changeset = form_data |> InputConverter.form_data_to_changeset_draft()
    pending_dataset = Ecto.Changeset.apply_changes(changeset)
    {:ok, _} = Datasets.update(pending_dataset)

    {_, updated_socket} =
      form_data
      |> InputConverter.form_data_to_ui_changeset()
      |> complete_validation(socket)

    success_message =
      case socket.assigns.changeset.valid? do
        true -> "Saved successfully."
        false -> "Saved successfully. You may need to fix errors before publishing."
      end

    changeset =
      socket.assigns.changeset
      |> Dataset.validate_unique_system_name()
      |> Map.put(:action, :update)

    {:noreply, assign(updated_socket, save_success: true, success_message: success_message, unsaved_changes: false, changeset: changeset)}
  end

  def handle_event("unsaved-changes-canceled", _, socket) do
    {:noreply, assign(socket, show_unsaved_changes_modal: false)}
  end

  def handle_event("cancel-edit", _, socket) do
    case socket.assigns.unsaved_changes do
      true ->
        {:noreply, assign(socket, show_unsaved_changes_modal: true)}

      false ->
        {:noreply, redirect(socket, to: "/")}
    end
  end

  def handle_event("force-cancel-edit", _, socket) do
    {:noreply, redirect(socket, to: "/")}
  end

  #TODO clean this up - maybe move to input converter
  def handle_info({:form_save, form_changes}, socket) do
    technical_changes = socket.assigns.changeset
      |> Changeset.get_change(:technical)
      |> Map.get(:changes)
      |> Map.merge(form_changes)

    business_changes = socket.assigns.changeset
      |> Changeset.get_change(:business)
      |> Map.get(:changes)
      |> Map.merge(form_changes)

    new_changes = %{technical: technical_changes, business: business_changes, id: socket.assigns.dataset.id}

    new_changeset = Dataset.changeset_for_draft(%Dataset{}, new_changes)

    pending_dataset = Changeset.apply_changes(new_changeset)
    {:ok, _} = Datasets.update(pending_dataset)

    # new_changeset
    # |> Dataset.validate_unique_system_name()
    # |> Map.put(:action, :update)

    # {:noreply, assign(socket, changeset: new_changeset)}
    {:noreply, socket}
  end

  def handle_info({:add_data_dictionary_field_cancelled}, socket) do
    {:noreply, assign(socket, add_data_dictionary_field_visible: false)}
  end

  def handle_info({:remove_data_dictionary_field_cancelled}, socket) do
    {:noreply, assign(socket, remove_data_dictionary_field_visible: false)}
  end
  # TODO add these back in
  # def handle_info({:add_data_dictionary_field_succeeded, field_id}, socket) do
  #   dataset = Datasets.get(socket.assigns.dataset.id)
  #   changeset = InputConverter.andi_dataset_to_full_ui_changeset(dataset)

  #   {:noreply,
  #    assign(socket,
  #      changeset: changeset,
  #      selected_field_id: field_id,
  #      add_data_dictionary_field_visible: false,
  #      new_field_initial_render: true
  #    )}
  # end

  # def handle_info({:remove_data_dictionary_field_succeeded, deleted_field_parent_id, deleted_field_index}, socket) do
  #   new_selected_field =
  #     socket.assigns.changeset
  #     |> get_new_selected_field(deleted_field_parent_id, deleted_field_index)

  #   new_selected_field_id =
  #     case new_selected_field do
  #       :no_dictionary ->
  #         :no_dictionary

  #       new_selected ->
  #         Changeset.fetch_field!(new_selected, :id)
  #     end

  #   dataset = Datasets.get(socket.assigns.dataset.id)
  #   changeset = InputConverter.andi_dataset_to_full_ui_changeset(dataset)

  #   {:noreply,
  #    assign(socket,
  #      changeset: changeset,
  #      selected_field_id: new_selected_field_id,
  #      new_field_initial_render: true,
  #      remove_data_dictionary_field_visible: false
  #    )}
  # end

  def handle_info({:assign_crontab}, socket) do
    socket = reset_save_success(socket)

    dataset = Datasets.get(socket.assigns.dataset.id)

    changeset =
      dataset
      |> InputConverter.andi_dataset_to_full_ui_changeset()
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  # This handle_info takes care of all exceptions in a generic way.
  # Expected errors should be handled in specific handlers.
  # Flags should be reset here.
  def handle_info({:EXIT, _pid, {_error, _stacktrace}}, socket) do
    {:noreply, assign(socket, page_error: true, testing: false, save_success: false)}
  end

  def handle_info(message, socket) do
    Logger.debug(inspect(message))
    {:noreply, socket}
  end

  defp complete_validation(changeset, socket) do
    socket = reset_save_success(socket)
    new_changeset = Map.put(changeset, :action, :update)
    current_form = socket.assigns.current_data_dictionary_item

    # updated_current_field =
    #   case current_form do
    #     :no_dictionary ->
    #       :no_dictionary

    #     _ ->
    #       new_form_template = find_field_in_changeset(new_changeset, current_form.source.changes.id) |> form_for(nil)
    #       %{current_form | source: new_form_template.source, params: new_form_template.params}
    #   end

    # {:noreply, assign(socket, changeset: new_changeset, current_data_dictionary_item: updated_current_field)}
    {:noreply, assign(socket, changeset: new_changeset)}
  end

  defp mark_changes({:noreply, socket}) do
    {:noreply, assign(socket, unsaved_changes: true)}
  end


  # TODO add this back ik
  # defp get_new_selected_field(changeset, parent_id, deleted_field_index) do
  #   technical_changeset = Changeset.fetch_change!(changeset, :technical)
  #   technical_id = Changeset.fetch_change!(technical_changeset, :id)

  #   if parent_id == technical_id do
  #     technical_changeset
  #     |> Changeset.fetch_change!(:schema)
  #     |> get_next_sibling(deleted_field_index)
  #   else
  #     changeset
  #     |> find_field_in_changeset(parent_id)
  #     |> Changeset.get_change(:subSchema, [])
  #     |> get_next_sibling(deleted_field_index)
  #   end
  # end

  # defp get_next_sibling(parent_schema, _) when length(parent_schema) <= 1, do: :no_dictionary

  # defp get_next_sibling(parent_schema, deleted_field_index) when deleted_field_index == 0 do
  #   Enum.at(parent_schema, deleted_field_index + 1)
  # end

  # defp get_next_sibling(parent_schema, deleted_field_index) do
  #   Enum.at(parent_schema, deleted_field_index - 1)
  # end

  defp reset_save_success(socket), do: assign(socket, save_success: false, has_validation_errors: false)
end
