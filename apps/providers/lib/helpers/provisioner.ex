defmodule Providers.Helpers.Provisioner do
  @moduledoc """
  Recursively traverses a map, list, or struct and executes any providers found. Raises exceptions from providers as `ProviderNotFound`
  """
  alias Provider.Exceptions
  require Logger

  def provision(%module{} = struct) do
    destructed_struct = Map.from_struct(struct) |> provision()
    struct(module, destructed_struct)
  end

  def provision(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {key, run_if_provider(value)} end)
    |> Enum.into(%{})
  end

  def provision(list) when is_list(list) do
    Enum.map(list, &run_if_provider/1)
  end

  defp run_if_provider(%{provider: provider_name, version: version} = provider) do
    Logger.debug("Running provider #{provider_name} at version #{version}")
    provider_opts = Map.get(provider, :opts, %{})
    provider_module = provider_module(provider_name)

    try do
      apply(provider_module, :provide, [version, provider_opts])
    rescue
      error ->
        Logger.error(Exception.format(:error, error, __STACKTRACE__))
        raise(
          Exceptions.ProviderError,
          message: "Provider #{provider_name} at version #{version} encountered an error: #{error.message}"
        )
    end
  end

  defp run_if_provider(value) when is_map(value) or is_list(value), do: provision(value)

  defp run_if_provider(not_provider), do: not_provider

  defp provider_module(provider_name) do
    # to_existing_atom errors if the atom doesn't exist. Module names are pre-existing atoms.
    String.to_existing_atom("Elixir.Providers.#{provider_name}")
  rescue
    _ -> raise Exceptions.ProviderNotFound, message: "Could not find Providers.#{provider_name}"
  end
end
