defmodule AndiWeb.EditLiveView.FinalizeFormTest do
  use AndiWeb.ConnCase
  use Phoenix.ConnTest
  import Phoenix.LiveViewTest

  use Placebo

  import FlokiHelpers,
    only: [
      get_values: 2,
      get_attributes: 3,
      find_elements: 2
    ]

  @url_path "/datasets/"

  describe "one-time ingestion" do
    setup %{conn: conn} do
      dataset =
        DatasetHelpers.create_dataset(%{
          technical: %{
            cadence: "once"
          }
        })

      DatasetHelpers.add_dataset_to_repo(dataset)

      assert {:ok, view, html} = live(conn, @url_path <> dataset.id)

      [
        view: view,
        html: html
      ]
    end

    test "shows the Immediate ingestion button selected", %{html: html} do
      refute Enum.empty?(get_attributes(html, "#form_data_technical_cadence_once", "checked"))
    end

    test "does not show cron scheduler", %{html: html} do
      assert Enum.empty?(find_elements(html, ".finalize-form__scheduler--visible"))
      refute Enum.empty?(find_elements(html, ".finalize-form__scheduler--hidden"))
    end
  end

  describe "repeat ingestion" do
    setup %{conn: conn} do
      dataset =
        DatasetHelpers.create_dataset(%{
          technical: %{
            cadence: "0 * * * * *"
          }
        })

      DatasetHelpers.add_dataset_to_repo(dataset)

      assert {:ok, view, html} = live(conn, @url_path <> dataset.id)

      [
        view: view,
        html: html
      ]
    end

    test "shows the repeat ingestion button selected", %{html: html} do
      refute Enum.empty?(get_attributes(html, "#form_data_technical_cadence_0__________", "checked"))
    end

    test "shows cron scheduler", %{html: html} do
      refute Enum.empty?(find_elements(html, ".finalize-form__scheduler--visible"))
      assert Enum.empty?(find_elements(html, ".finalize-form__scheduler--hidden"))

      assert "0 * * * * *" == get_crontab_from_html(html)
    end
  end

  defp get_crontab_from_html(html) do
    html
    |> get_values(".finalize-form-schedule-input__field")
    |> Enum.join(" ")
  end
end