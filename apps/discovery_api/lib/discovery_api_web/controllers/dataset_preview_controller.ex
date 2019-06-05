defmodule DiscoveryApiWeb.DatasetPreviewController do
  use DiscoveryApiWeb, :controller
  alias DiscoveryApiWeb.DatasetPrestoQueryService

  def fetch_preview(conn, _params) do
    columns =
      conn.assigns.model.systemName
      |> DatasetPrestoQueryService.preview_columns()

    conn.assigns.model.systemName
    |> DatasetPrestoQueryService.preview()
    |> return_preview(columns, conn)
  rescue
    _e in Prestige.Error -> json(conn, %{data: [], meta: %{columns: []}, message: "Something went wrong while fetching the preview."})
  end

  defp return_preview(rows, columns, conn), do: json(conn, %{data: rows, meta: %{columns: columns}})
end
