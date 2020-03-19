defmodule AndiWeb.EditLiveView.KeyValueEditor do
  @moduledoc """
    LiveComponent for an nested key/value form
  """
  use Phoenix.LiveComponent
  import Phoenix.HTML.Form
  import AndiWeb.ErrorHelpers

  alias Andi.InputSchemas.DisplayNames

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="url-form__<%= @css_label %> url-form-table">
      <div class="url-form-table__title"><%= DisplayNames.get(@field) %></div>
      <table class="url-form-table__table">
      <tr class="url-form-table__row url-form-table__row--bordered">
        <th class="url-form-table__cell url-form-table__cell--bordered url-form-table__cell--header">KEY</th>
        <th class="url-form-table__cell url-form-table__cell--bordered url-form-table__cell--header" colspan="2" >VALUE</th>
      </tr>
      <%= if is_set?(@form, @field) do %>
        <%= inputs_for @form, @field, fn f -> %>
        <tr class="url-form-table__row url-form-table__row--bordered">
          <td class="url-form-table__cell url-form-table__cell--bordered">
            <%= text_input(f, :key, class: "input full-width url-form__#{@css_label}-key-input #{input_value(f, :id)}") %>
          </td>
          <td class="url-form-table__cell url-form-table__cell--bordered">
            <%= text_input(f, :value, class: "input full-width url-form__#{@css_label}-value-input #{input_value(f, :id)}") %>
          </td>
          <td class="url-form-table__cell url-form-table__cell--delete">
            <div class="url-form__<%= @css_label %>-delete-btn url-form-table__btn" phx-click="remove" phx-value-id="<%= input_value(f, :id) %>" phx-value-field="<%= @field %>">
              <img src="/images/remove.svg" alt="Remove"/>
            </div>
          </td>
        </tr>
        <% end %>
      <% end %>
      </table>
      <div class="url-form__<%= @css_label %>-add-btn url-form-table__btn" style="margin-top: 0.8em;" phx-click="add" phx-value-field="<%= @field %>">
        <img src="/images/add.svg" alt="Add"/>
      </div>
      <%= error_tag(@form, @field, bind_to_input: false) %>
    </div>
    """
  end

  defp is_set?(%{source: %{changes: changes}}, field), do: changes[field] != nil
end
