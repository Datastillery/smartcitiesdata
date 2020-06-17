defmodule Reaper.Event.Handler do
  @moduledoc "This modules processes all events for Reaper"
  use Brook.Event.Handler

  import SmartCity.Event,
    only: [
      dataset_update: 0,
      error_dataset_update: 0,
      data_ingest_start: 0,
      data_extract_start: 0,
      data_extract_end: 0,
      file_ingest_start: 0,
      file_ingest_end: 0,
      dataset_disable: 0,
      dataset_delete: 0
    ]

  alias Reaper.Collections.{Extractions, FileIngestions}

  @instance Reaper.Application.instance()

  def handle_event(%Brook.Event{type: dataset_update(), data: %SmartCity.Dataset{} = dataset}) do
    dataset_update()
    |> add_event_count(dataset.id)

    Extractions.update_dataset(dataset)
    FileIngestions.update_dataset(dataset)
    Reaper.Event.Handlers.DatasetUpdate.handle(dataset)
  rescue
    reason ->
      Brook.Event.send(@instance, error_dataset_update(), :reaper, %{"reason" => reason, "dataset" => dataset})
      :discard
  end

  def handle_event(%Brook.Event{type: data_extract_start(), data: %SmartCity.Dataset{} = dataset}) do
    data_extract_start()
    |> add_event_count(dataset.id)

    if Extractions.is_enabled?(dataset.id) do
      Reaper.Horde.Supervisor.start_data_extract(dataset)

      if Extractions.should_send_data_ingest_start?(dataset) do
        Brook.Event.send(@instance, data_ingest_start(), :reaper, dataset)
      end

      Extractions.update_started_timestamp(dataset.id)
    end

    :ok
  end

  def handle_event(%Brook.Event{type: data_extract_end(), data: %SmartCity.Dataset{} = dataset}) do
    data_extract_end()
    |> add_event_count(dataset.id)

    Extractions.update_last_fetched_timestamp(dataset.id)
  end

  def handle_event(%Brook.Event{type: file_ingest_start(), data: %SmartCity.Dataset{} = dataset}) do
    file_ingest_start()
    |> add_event_count(dataset.id)

    if FileIngestions.is_enabled?(dataset.id) do
      Reaper.Horde.Supervisor.start_file_ingest(dataset)

      FileIngestions.update_started_timestamp(dataset.id)
    end

    :ok
  end

  def handle_event(%Brook.Event{type: file_ingest_end(), data: %SmartCity.Dataset{} = dataset}) do
    file_ingest_end()
    |> add_event_count(dataset.id)

    FileIngestions.update_last_fetched_timestamp(dataset.id)
  end

  def handle_event(%Brook.Event{
        type: file_ingest_end(),
        data: %SmartCity.HostedFile{mime_type: "application/geo+json"} = hosted_file
      }) do
    file_ingest_end()
    |> add_event_count(hosted_file.dataset_id)

    shapefile_dataset = FileIngestions.get_dataset!(hosted_file.dataset_id)

    geojson_dataset = %{
      shapefile_dataset
      | technical: %{
          shapefile_dataset.technical
          | sourceFormat: hosted_file.mime_type,
            sourceUrl: "s3://#{hosted_file.bucket}/#{hosted_file.key}"
        }
    }

    Brook.Event.send(@instance, data_extract_start(), :reaper, geojson_dataset)
  end

  def handle_event(%Brook.Event{type: dataset_disable(), data: %SmartCity.Dataset{} = dataset}) do
    dataset_disable()
    |> add_event_count(dataset.id)

    Reaper.Event.Handlers.DatasetDisable.handle(dataset)
    Extractions.disable_dataset(dataset.id)
    FileIngestions.disable_dataset(dataset.id)
  end

  def handle_event(%Brook.Event{type: dataset_delete(), data: %SmartCity.Dataset{} = dataset}) do
    dataset_delete()
    |> add_event_count(dataset.id)

    Reaper.Event.Handlers.DatasetDelete.handle(dataset)
    Extractions.delete_dataset(dataset.id)
    FileIngestions.disable_dataset(dataset.id)
  end

  defp add_event_count(event_type, dataset_id) do
    [
      app: "reaper",
      author: "reaper",
      dataset_id: "dataset_id",
      event_type: "event_type"
    ]
    |> TelemetryEvent.TelemetryHelper.add_event_count()
  end
end
