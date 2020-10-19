defmodule Andi.Application do
  @moduledoc false

  use Application

  require Logger

  @instance_name Andi.instance_name()

  def start(_type, _args) do
    children =
      [
        AndiWeb.Endpoint,
        ecto_repo(),
        guardian_db_sweeper(),
        {Brook, Application.get_env(:andi, :brook)},
        Andi.DatasetCache,
        Andi.Migration.Migrations,
        Andi.Scheduler,
        elsa()
      ]
      |> TelemetryEvent.config_init_server(@instance_name)
      |> List.flatten()

    set_auth0_credentials()

    opts = [strategy: :one_for_one, name: Andi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp elsa() do
    case Application.get_env(:andi, :kafka_endpoints) do
      nil ->
        []

      _ ->
        {Elsa.Supervisor,
         endpoints: Application.get_env(:andi, :kafka_endpoints),
         name: :andi_elsa,
         connection: :andi_reader,
         group_consumer: [
           name: "andi_reader",
           group: "andi_reader_group",
           topics: [Application.get_env(:andi, :dead_letter_topic)],
           handler: Andi.MessageHandler,
           handler_init_args: [],
           config: [
             begin_offset: :latest
           ]
         ]}
    end
  end

  defp ecto_repo do
    Application.get_env(:andi, Andi.Repo)
    |> case do
      nil -> []
      _ -> Supervisor.Spec.worker(Andi.Repo, [])
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AndiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def set_auth0_credentials() do
    endpoint = Application.get_env(:andi, :secrets_endpoint)

    if is_nil(endpoint) || String.length(endpoint) == 0 do
      Logger.warn("No secrets endpoint. ANDI will not be able to authenticate users")
      []
    else
      case Andi.SecretRetriever.retrieve_auth0_credentials() do
        {:ok, credentials} ->
          Application.put_env(:ueberauth, Ueberauth.Strategy.Auth0.OAuth,
            domain: System.get_env("AUTH0_DOMAIN"),
            client_id: System.get_env("AUTH0_CLIENT_ID"),
            client_secret: Map.get(credentials, "auth0_client_secret")
          )

        {:error, error} ->
          raise RuntimeError, message: "Could not start application, encountered error while retrieving Auth0 keys: #{error}"

        nil ->
          raise RuntimeError,
            message: "Could not start application, failed to retrieve Auth0 keys from Vault."
      end
    end
  end

  defp guardian_db_sweeper do
    Application.get_env(:andi, Guardian.DB)
    |> case do
      nil ->
        []

      config ->
        Application.put_env(:guardian, Guardian.DB, config)
        Supervisor.Spec.worker(Guardian.DB.Token.SweeperServer, [])
    end
  end
end
