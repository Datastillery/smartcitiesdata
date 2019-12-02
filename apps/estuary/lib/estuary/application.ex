defmodule Estuary.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @elsa_endpoint Application.get_env(:estuary, :elsa_endpoint)
  @event_stream_topic Application.get_env(:estuary, :event_stream_topic)

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    validate_topic_exists()
    validate_table_exists()

    children = []

    opts = [strategy: :one_for_one, name: Estuary.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp validate_topic_exists do
    case Elsa.Topic.exists?(@elsa_endpoint, @event_stream_topic) do
      true -> :ok
      false -> Elsa.Topic.create(@elsa_endpoint, @event_stream_topic)
    end
  end

  defp validate_table_exists do
    table_name = "event_stream"
    query = "CREATE TABLE #{table_name} (id int)"
    Prestige.execute(query)
    |> Prestige.prefetch
  end
end
