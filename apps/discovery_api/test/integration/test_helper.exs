alias DiscoveryApi.Test.Helper

Divo.Suite.start(auto_start: false)
Mix.Tasks.Ecto.Create.run([])
Mix.Tasks.Ecto.Migrate.run([])
Application.ensure_all_started(:discovery_api)
Helper.wait_for_brook_to_be_ready()
Faker.start()
ExUnit.start()

defmodule URLResolver do
  def resolve_url(url) do
    "./test/integration/schemas/#{url}"
    |> String.split("#")
    |> List.last()
    |> File.read!()
    |> Jason.decode!()
    |> remove_urls()
  end

  def remove_urls(map) do
    Map.put(map, "id", "./test/integration/schemas/")
  end
end
