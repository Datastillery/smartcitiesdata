defmodule Pipeline.Writer do
  @moduledoc """
  Behaviour describing how to interact with component edges that receive data.
  """

  @callback init(keyword()) :: :ok | {:error, term()}
  @callback write([term()], keyword()) :: :ok | {:error, term()}
  @callback terminate(keyword()) :: :ok | {:error, term()}
  @callback compact(keyword()) :: :ok | {:error, term()}
  @callback delete_topic(keyword()) :: :ok | {:error, term()}
  @callback rename_table(keyword()) :: :ok | {:error, term()}

  @optional_callbacks compact: 1, terminate: 1, delete_topic: 1, rename_table: 1
end
