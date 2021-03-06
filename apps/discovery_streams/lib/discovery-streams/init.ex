defmodule DiscoveryStreams.Init do
  @moduledoc """
  Implementation of `Initializer` behaviour to reconnect to
  pre-existing event state.
  """
  use Initializer,
    name: __MODULE__,
    supervisor: DiscoveryStreams.Stream.Supervisor

  def on_start(state) do
    with {:ok, view_state} <- Brook.get_all(:discovery_streams, :streaming_datasets_by_system_name) do
      Enum.each(view_state, fn {_, dataset_id} -> DiscoveryStreams.Stream.Supervisor.start_child(dataset_id) end)

      Ok.ok(state)
    end
  end
end
