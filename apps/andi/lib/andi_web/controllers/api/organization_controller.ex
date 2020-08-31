defmodule AndiWeb.API.OrganizationController do
  @moduledoc """
  Creates new organizations and retrieves existing ones in ViewState.
  """
  use AndiWeb, :controller

  require Logger
  alias SmartCity.Organization
  alias Andi.Services.OrgStore
  import Andi
  import SmartCity.Event, only: [organization_update: 0, dataset_harvest_start: 0]

  @doc """
  Parse a data message to create a new organization to store in ViewState
  """
  @spec create(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def create(conn, _params) do
    message =
      conn.body_params
      |> remove_blank_keys()
      |> add_uuid()

    with :ok <- ensure_new_org(message["id"]),
         {:ok, organization} <- Organization.new(message),
         :ok <- write_organization(organization) do
      conn
      |> put_status(:created)
      |> json(organization)
    else
      error ->
        Logger.error("Failed to create organization: #{inspect(error)}")

        conn
        |> put_status(:internal_server_error)
        |> json("Unable to process your request: #{inspect(error)}")
    end
  end

  defp ensure_new_org(id) do
    case OrgStore.get(id) do
      {:ok, %Organization{}} ->
        Logger.error("ID #{id} already exists")
        %RuntimeError{message: "ID #{id} already exists"}

      {:ok, nil} ->
        :ok

      _ ->
        %RuntimeError{message: "Unknown error for #{id}"}
    end
  end

  defp remove_blank_keys(message) do
    message
    |> Enum.filter(fn {_, v} -> v != "" end)
    |> Map.new()
  end

  defp add_uuid(message) do
    uuid = UUID.uuid4()

    Map.merge(message, %{"id" => uuid}, fn _k, v1, _v2 -> v1 end)
  end

  defp write_organization(org) do
    case Brook.Event.send(instance_name(), organization_update(), :andi, org) do
      :ok ->
        :ok

      error ->
        error
    end
  end

  @doc """
  Retrieve all existing organizations stored in ViewState
  """
  @spec get_all(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def get_all(conn, _params) do
    case OrgStore.get_all() do
      {:ok, orgs} ->
        conn
        |> put_status(:ok)
        |> json(orgs)

      {_, error} ->
        Logger.error("Failed to retrieve organizations: #{inspect(error)}")

        conn
        |> put_status(:not_found)
        |> json("Unable to process your request")
    end
  end

  @doc """
  Sends a user:organization:associate event
  """
  def add_users_to_organization(conn, %{"org_id" => org_id, "users" => users}) do
    case Andi.Services.UserOrganizationAssociateService.associate(org_id, users) do
      :ok ->
        conn
        |> put_status(200)
        |> json(conn.body_params)

      {:error, :invalid_org} ->
        conn
        |> put_status(400)
        |> json("The organization #{org_id} does not exist")

      {:error, _} ->
        conn
        |> put_status(500)
        |> put_view(AndiWeb.ErrorView)
        |> render("500.json")
    end
  end
end
