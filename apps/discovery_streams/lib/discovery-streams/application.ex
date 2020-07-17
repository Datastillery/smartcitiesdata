defmodule DiscoveryStreams.MetricsExporter do
  @moduledoc false
  use Prometheus.PlugExporter
end

defmodule DiscoveryStreams.Application do
  @moduledoc false
  use Application

  require Cachex.Spec

  def instance(), do: :discovery_streams_brook

  def start(_type, _args) do
    import Supervisor.Spec

    DiscoveryStreams.MetricsExporter.setup()
    DiscoveryStreamsWeb.Endpoint.Instrumenter.setup()

    opts = [strategy: :one_for_one, name: DiscoveryStreams.Supervisor]

    children =
      [
        DiscoveryStreams.CachexSupervisor,
        supervisor(DiscoveryStreamsWeb.Endpoint, []),
        libcluster(),
        metrics(),
        DiscoveryStreams.CacheGenserver,
        {Brook, Application.get_env(:discovery_streams, :brook)},
        {DynamicSupervisor, strategy: :one_for_one, name: DiscoveryStreams.Dynamic.Supervisor},
        DiscoveryStreamsWeb.Presence,
        DiscoveryStreamsWeb.Presence.Server
      ]
      |> List.flatten()

    Supervisor.start_link(children, opts)
  end

  defp libcluster do
    case Application.get_env(:libcluster, :topologies) do
      nil -> []
      topologies -> {Cluster.Supervisor, [topologies, [name: StreamingConsumer.ClusterSupervisor]]}
    end
  end

  defp kaffe do
    case Application.get_env(:kaffe, :consumer)[:endpoints] do
      nil ->
        []

      _ ->
        [
          Supervisor.Spec.supervisor(Kaffe.GroupMemberSupervisor, []),
          DiscoveryStreams.TopicSubscriber
        ]
    end
  end

  defp metrics() do
    case Application.get_env(:discovery_streams, :metrics_port) do
      nil ->
        []

      metrics_port ->
        Plug.Cowboy.child_spec(
          scheme: :http,
          plug: DiscoveryStreams.MetricsExporter,
          options: [port: metrics_port]
        )
    end
  end
end
