use Mix.Config

config :telemetry_event,
  init_server: false,
  metrics_options: [
    [
      metric_type_and_name: [:counter, :any_events_handled, :count],
      tags: [:any_app, :any_author, :any_dataset_id, :any_event_type]
    ],
    [
      metric_type_and_name: [:counter, :any_dead_letters_handled, :count],
      tags: [:any_dataset_id, :any_reason]
    ],
    [
      metric_type_and_name: [:sum, :any_dataset_compaction_duration_total, :duration],
      tags: [:any_app, :any_system_name]
    ]
  ]
