defmodule Estuary.StartTest do
  use ExUnit.Case
  use Divo

  @elsa_endpoint Application.get_env(:estuary, :elsa_endpoint)
  @event_stream_topic Application.get_env(:estuary, :event_stream_topic)

  test "Topic is created when Estuary starts" do
    assert Elsa.Topic.exists?(@elsa_endpoint, @event_stream_topic)
  end
end
