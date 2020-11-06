defmodule AndiWeb.ExtractSteps.ExtractHttpStepForm do
  @moduledoc """
  LiveComponent for an extract step with type HTTP
  """
  use Phoenix.LiveComponent
  import Phoenix.HTML
  import Phoenix.HTML.Form
  require Logger

  alias Andi.InputSchemas.Datasets.ExtractHttpStep
  alias Andi.InputSchemas.Datasets.ExtractHeader
  alias Andi.InputSchemas.Datasets.ExtractQueryParam
  alias AndiWeb.EditLiveView.KeyValueEditor
  alias AndiWeb.ErrorHelpers
  alias AndiWeb.Views.Options
  alias AndiWeb.Views.DisplayNames
  alias AndiWeb.Views.HttpStatusDescriptions
  alias AndiWeb.Helpers.FormTools

  def mount(socket) do
    {:ok,
     assign(socket,
       testing: false,
       test_results: nil,
       visibility: "expanded",
       validation_status: "collapsed"
     )}
  end

  def render(assigns) do
    ~L"""
        <div id="step-<%= @id %>" class="extract-step-container extract-http-step-form">
          <div class="extract-step-header full-width">
            <h3>HTTP</h3>
            <div class="edit-buttons">
            <div class="extract-step-header__up" phx-click="move-extract-step" phx-value-id=<%= @id %> phx-value-move-index="-1"></div>
            <div class="extract-step-header__down" phx-click="move-extract-step" phx-value-id=<%= @id %> phx-value-move-index="1"></div>
              <div class="extract-step-header__remove"></div>
            </div>
          </div>

          <%= f = form_for @changeset, "#", [phx_change: :validate, phx_target: "#step-#{@id}", as: :form_data] %>

            <div class="component-edit-section--<%= @visibility %>">
              <div class="extract-http-step-form-edit-section form-grid">

                <div class="extract-http-step-form__method">
                  <%= label(f, :action, DisplayNames.get(:method), class: "label label--required") %>
                  <%= select(f, :action, get_http_methods(), id: "http_method", class: "extract-http-step-form__method select") %>
                  <%= ErrorHelpers.error_tag(f, :action) %>
                </div>

                <div class="extract-http-step-form__url">
                  <%= label(f, :url, DisplayNames.get(:url), class: "label label--required") %>
                  <%= text_input(f, :url, class: "input full-width", disabled: @testing) %>
                  <%= ErrorHelpers.error_tag(f, :url, bind_to_input: false) %>
                </div>

                <%= live_component(@socket, KeyValueEditor, id: "key_value_editor_queryParams" <> @extract_step.id, css_label: "source-query-params", form: f, field: :queryParams, target: "step-#{@id}") %>

                <%= live_component(@socket, KeyValueEditor, id: "key_value_editor_headers" <> @extract_step.id, css_label: "source-headers", form: f, field: :headers, target: "step-" <> @id) %>

                <%= if input_value(f, :action) == "POST" do %>
                  <div class="extract-http-step-form__body">
                    <%= label(f, :body, DisplayNames.get(:body),  class: "label") %>
                    <%= textarea(f, :body, class: "input full-width", phx_hook: "prettify", disabled: @testing) %>
                    <%= ErrorHelpers.error_tag(f, :body, bind_to_input: false) %>
                  </div>
                <% end %>

                <div class="extract-http-step-form__test-section">
                  <button type="button" class="extract_step__test-btn btn--test btn btn--large btn--action" phx-click="test_url" phx-target="#step-<%= @id %>" <%= disabled?(@testing) %>>Test</button>
                  <%= if @test_results do %>
                    <div class="test-status">
                    Status: <span class="test-status__code <%= status_class(@test_results) %>"><%= @test_results |> Map.get(:status) |> HttpStatusDescriptions.simple() %></span>
                    <%= status_tooltip(@test_results) %>
                    Time: <span class="test-status__time"><%= @test_results |> Map.get(:time) %></span> ms
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </form>
        </div>
    """
  end

  def handle_event("validate", %{"form_data" => form_data, "_target" => ["form_data", "url"]}, socket) do
    form_data
    |> FormTools.adjust_extract_query_params_for_url()
    |> ExtractHttpStep.changeset_from_form_data()
    |> complete_validation(socket)
  end

  def handle_event("validate", %{"form_data" => form_data, "_target" => ["form_data", "queryParams" | _]}, socket) do
    form_data
    |> FormTools.adjust_extract_url_for_query_params()
    |> ExtractHttpStep.changeset_from_form_data()
    |> complete_validation(socket)
  end

  def handle_event("validate", %{"form_data" => form_data}, socket) do
    form_data
    |> AtomicMap.convert(safe: false, underscore: false)
    |> ExtractHttpStep.changeset()
    |> complete_validation(socket)
  end

  def handle_event("validate", _, socket) do
    send(socket.parent_pid, :page_error)

    {:noreply, socket}
  end

  def handle_event("add", %{"field" => "queryParams"}, %{assigns: %{changeset: changeset}} = socket) do
    query_params = Ecto.Changeset.get_field(changeset, :queryParams, [])
    new_query_param = ExtractQueryParam.changeset(%{})

    new_changes =
      changeset
      |> Ecto.Changeset.put_embed(:queryParams, query_params ++ [new_query_param])

    {:noreply, assign(socket, changeset: new_changes)}
  end

  def handle_event("add", %{"field" => "headers"}, %{assigns: %{changeset: changeset}} = socket) do
    headers = Ecto.Changeset.get_field(changeset, :headers, [])
    new_header = ExtractHeader.changeset(%{})

    new_changes =
      changeset
      |> Ecto.Changeset.put_embed(:headers, headers ++ [new_header])

    {:noreply, assign(socket, changeset: new_changes)}
  end

  def handle_event("remove", %{"id" => query_param_id, "field" => "queryParams"}, socket) do
    updated_query_params =
      socket.assigns.changeset
      |> Ecto.Changeset.get_field(:queryParams)
      |> remove_key_value(query_param_id)

    new_changset = Ecto.Changeset.put_embed(socket.assigns.changeset, :queryParams, updated_query_params)

    {:noreply, assign(socket, changeset: new_changset)}
  end

  def handle_event("remove", %{"id" => header_id, "field" => "headers"}, socket) do
    updated_headers =
      socket.assigns.changeset
      |> Ecto.Changeset.get_field(:headers)
      |> remove_key_value(header_id)

    new_changset = Ecto.Changeset.put_embed(socket.assigns.changeset, :headers, updated_headers)

    {:noreply, assign(socket, changeset: new_changset)}
  end

  def handle_event("test_url", _, socket) do
    changes = Ecto.Changeset.apply_changes(socket.assigns.changeset)
    url = Map.get(changes, :url) |> Andi.URI.clear_query_params()
    query_params = key_values_to_keyword_list(changes, :queryParams)
    headers = key_values_to_keyword_list(changes, :headers)

    # TODO
    # Task.async(fn ->
    #   {:test_results, Andi.Services.UrlTest.test(url, query_params: query_params, headers: headers)}
    # end)
    test_results = Andi.Services.UrlTest.test(url, query_params: query_params, headers: headers)
    # {:noreply, assign(socket, testing: true)}
    {:noreply, assign(socket, test_results: test_results)}
  end

  def handle_info({_, {:test_results, results}}, socket) do
    send(self(), {:test_results, results})
    {:noreply, assign(socket, test_results: results, testing: false)}
  end

  # This handle_info takes care of all exceptions in a generic way.
  # Expected errors should be handled in specific handlers.
  # Flags should be reset here.
  def handle_info({:EXIT, _pid, {_error, _stacktrace}}, socket) do
    send(socket.parent_pid, :page_error)
    {:noreply, assign(socket, page_error: true, testing: false, save_success: false)}
  end

  def handle_info(message, socket) do
    Logger.debug(inspect(message))
    {:noreply, socket}
  end

  defp remove_key_value(key_value_list, id) do
    Enum.reduce_while(key_value_list, key_value_list, fn key_value, acc ->
      case key_value.id == id do
        true -> {:halt, List.delete(key_value_list, key_value)}
        false -> {:cont, acc}
      end
    end)
  end

  defp disabled?(true), do: "disabled"
  defp disabled?(_), do: ""

  defp status_class(%{status: status}) when status in 200..399, do: "test-status__code--good"
  defp status_class(%{status: _}), do: "test-status__code--bad"
  defp status_tooltip(%{status: status}) when status in 200..399, do: status_tooltip(%{status: status}, "shown")

  defp status_tooltip(%{status: status}, modifier \\ "shown") do
    assigns = %{
      description: HttpStatusDescriptions.get(status),
      modifier: modifier
    }

    ~E(<sup class="test-status__tooltip-wrapper"><i phx-hook="addTooltip" data-tooltip-content="<%= @description %>" class="material-icons-outlined test-status__tooltip--<%= @modifier %>">info</i></sup>)
  end

  defp key_values_to_keyword_list(form_data, field) do
    form_data
    |> Map.get(field, [])
    |> Enum.map(fn %{key: key, value: value} -> {key, value} end)
  end

  defp get_http_methods(), do: map_to_dropdown_options(Options.http_method())

  defp map_to_dropdown_options(options) do
    Enum.map(options, fn {actual_value, description} -> [key: description, value: actual_value] end)
  end

  defp update_validation_status(%{assigns: %{validation_status: validation_status, visibility: visibility}} = socket)
       when validation_status in ["valid", "invalid"] or visibility == "collapsed" do
    new_status = get_new_validation_status(socket.assigns.changeset)
    send(socket.parent_pid, {:validation_status, {socket.assigns.extract_step.id, new_status}})
    assign(socket, validation_status: new_status)
  end

  defp update_validation_status(%{assigns: %{visibility: visibility}} = socket), do: assign(socket, validation_status: visibility)

  defp get_new_validation_status(changeset) do
    case changeset.valid? do
      true -> "valid"
      false -> "invalid"
    end
  end

  defp complete_validation(changeset, socket) do
    new_changeset = Map.put(changeset, :action, :update)
    send(socket.parent_pid, :form_update)
    send(self(), {:step_update, socket.assigns.id, new_changeset})

    {:noreply, assign(socket, changeset: new_changeset) |> update_validation_status()}
  end
end
