defmodule AndiWeb.FormSection do
  @moduledoc """
  Macro defining common functions for LiveViews representing sections of the edit dataset page
  """

  defmacro __using__(opts) do
    schema_module = Keyword.fetch!(opts, :schema_module)

    quote do
      import Phoenix.LiveView
      alias Andi.InputSchemas.Datasets

      def handle_event("save", _, socket) do
        changeset =
          socket.assigns.changeset
          |> Map.put(:action, :update)

        AndiWeb.Endpoint.broadcast_from(self(), "form-save", "form-save", %{form_changeset: changeset})

        new_validation_status = get_new_validation_status(changeset)

        {:noreply, assign(socket, changeset: changeset, validation_status: new_validation_status)}
      end

      def handle_event("toggle-component-visibility", %{"component-expand" => next_component}, socket) do
        new_validation_status = get_new_validation_status(socket.assigns.changeset)

        AndiWeb.Endpoint.broadcast_from(self(), "toggle-visibility", "toggle-component-visibility", %{expand: next_component})

        {:noreply, assign(socket, visibility: "collapsed", validation_status: new_validation_status)}
      end

      def handle_event("toggle-component-visibility", _, socket) do
        current_visibility = Map.get(socket.assigns, :visibility)

        new_visibility =
          case current_visibility do
            "expanded" -> "collapsed"
            "collapsed" -> "expanded"
          end

        {:noreply, assign(socket, visibility: new_visibility) |> update_validation_status()}
      end

      def handle_info(%{topic: "form-save", event: "form-save"}, socket) do
        new_validation_status =
          case socket.assigns.changeset.valid? do
            true -> "valid"
            false -> "invalid"
          end

        {:noreply, assign(socket, validation_status: new_validation_status)}
      end

      def handle_info(%{topic: "form-save", event: "save-all"}, socket) do
        new_validation_status =
          case socket.assigns.changeset.valid? do
            true -> "valid"
            false -> "invalid"
          end

        {:ok, andi_dataset} = Datasets.save_form_changeset(socket.assigns.dataset_id, socket.assigns.changeset)

        new_changeset = apply(unquote(schema_module), :changeset_from_andi_dataset, [andi_dataset])

        {:noreply, assign(socket, changeset: new_changeset, validation_status: new_validation_status)}
      end

      def update_validation_status(%{assigns: %{validation_status: validation_status, visibility: visibility}} = socket)
          when validation_status in ["valid", "invalid"] or visibility == "collapsed" do
        assign(socket, validation_status: get_new_validation_status(socket.assigns.changeset))
      end

      def update_validation_status(%{assigns: %{visibility: visibility}} = socket), do: assign(socket, validation_status: visibility)

      def handle_event("cancel-edit", _, socket) do
        send(socket.parent_pid, :cancel_edit)
        {:noreply, socket}
      end

      defp get_new_validation_status(changeset) do
        case changeset.valid? do
          true -> "valid"
          false -> "invalid"
        end
      end
    end
  end
end
