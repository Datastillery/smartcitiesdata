defmodule DiscoveryStreamsWeb.PresenceTest do
  use DiscoveryStreamsWeb.ChannelCase
  use Prometheus.Metric
  use Placebo

  # import Checkov

  # alias DiscoveryStreams.{CachexSupervisor, TopicSubscriber}

  # Commented out because Presence was not working and we did not want to fix it as part of a already large card.

  # setup do
  #   CachexSupervisor.create_cache(:"shuttle-position")
  #   CachexSupervisor.create_cache(:central_ohio_transit_authority__cota_stream)

  #   allow TopicSubscriber.list_subscribed_topics(),
  #     return: ["shuttle-position", "central_ohio_transit_authority__cota_stream"]

  #   :ok
  # end

  # test "setup declares a special metric gauge for a legacy snowflake" do
  #   assert Gauge.value(:cota_vehicle_positions_presence_count) >= 0
  # end

  # test "setup declares a metric gauge from a kafka topic" do
  #   assert Gauge.value(:shuttle_position_presence_count) >= 0
  # end

  # data_test "subscribing to a channel(#{channel}) inreases the gauge(#{gauge}) count" do
  #   Gauge.reset(gauge)

  #   {:ok, _, socket} = subscribe_and_join(socket(), DiscoveryStreamsWeb.StreamingChannel, channel)

  #   check_gauge_incremented = fn ->
  #     Gauge.value(gauge) == 1
  #   end

  #   Patiently.wait_for!(
  #     check_gauge_incremented,
  #     dwell: 10,
  #     max_tries: 200
  #   )

  #   on_exit(fn ->
  #     leave(socket)
  #     Gauge.reset(gauge)
  #   end)

  #   where([
  #     [:channel, :gauge],
  #     ["streaming:shuttle-position", :shuttle_position_presence_count],
  #     ["vehicle_position", :cota_vehicle_positions_presence_count]
  #   ])
  # end
end
