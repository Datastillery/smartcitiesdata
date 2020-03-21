defmodule DiscoveryStreamsWeb do
  @moduledoc false
  def controller do
    quote do
      use Phoenix.Controller, namespace: DiscoveryStreamsWeb
      import Plug.Conn
      import DiscoveryStreamsWeb.Router.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
