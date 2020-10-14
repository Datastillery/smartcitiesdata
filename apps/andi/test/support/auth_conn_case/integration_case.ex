defmodule AndiWeb.Test.AuthConnCase.IntegrationCase do
  @moduledoc """
  This module produced authorized and unauthorized connections for testing against Andi in an integration setup
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      alias AndiWeb.Router.Helpers, as: Routes

      @endpoint AndiWeb.Endpoint
    end
  end

  alias Andi.Test.AuthConnCase.AuthHelper

  setup _tags do
    AuthHelper.build_connections()
  end

  setup_all do
    exit_hook = AuthHelper.setup_jwks()
    on_exit(exit_hook)

    :ok
  end
end
