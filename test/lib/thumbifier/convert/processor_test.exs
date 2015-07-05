defmodule ProcessorTest do
  use Thumbifier.ConnCase

  setup do
    remote_fixtures_path = "https://github.com/sysdia/thumbifier/raw/master/test/fixtures/files/"
    data = %{
      "api_grant" => "grant",
      "callback_url" => "http://mycallbackurl.com",
      "dimensions" => "100x100",
      "quality" => "72",
      "format" => "json",
      "frame" => "",
      "media_url" => remote_fixtures_path <> "pdf.pdf",
      "page" => "1",
      "personal_reference" => "123",
      "response_id" => "c6f05692-e293-411d-a1bd-d44918746838"
    }

    {:ok, data: data, remote_fixtures_path: remote_fixtures_path}
  end

  defp image_compare(expected_file_path, actual_data) do
    file_content = Base.decode64(actual_data) |> elem(1)
    temp_file = System.tmp_dir! <> "/" <> Ecto.UUID.generate
    File.write!(temp_file, file_content)
    result = Sh.compare "-metric", "AE", "-fuzz", "26000", temp_file, expected_file_path, "null:"
    File.rm!(temp_file)
    result == "0"
  end

  test "process - posts error when provided media_url is too large", %{data: data} do
    assert Thumbifier.Convert.Processor.process(1, data) == %{status: "error", payload: "[0002] File limit exceeded"}
  end

  test "process - posts error when provided media_url is not supported", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "iff.iff"})
    result = Application.get_env(:thumbifier, :max_file_size)
    |> Thumbifier.Convert.Processor.process(data)

    assert result == %{status: "error", payload: "[0003] mime-type application/octet-stream not supported"}
  end

  test "process - success for tiff file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{
      "media_url" => remote_fixtures_path <> "tiff.tiff",
      "dimensions" => "250x250"
      })

    result = Application.get_env(:thumbifier, :max_file_size)
    |> Thumbifier.Convert.Processor.process(data)

    assert result.status == "ok"

    fixture = "test/fixtures/files/tiff_thumb.jpg"
    assert image_compare(fixture, result.payload) == true
  end

  test "process - success for png file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "png.png"})

    result = Application.get_env(:thumbifier, :max_file_size)
    |> Thumbifier.Convert.Processor.process(data)

    assert result.status == "ok"

    fixture = "test/fixtures/files/png_thumb.jpg"
    assert image_compare(fixture, result.payload) == true
  end

  test "process - success for gif file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "gif.gif"})

    result = Application.get_env(:thumbifier, :max_file_size)
    |> Thumbifier.Convert.Processor.process(data)

    assert result.status == "ok"

    fixture = "test/fixtures/files/gif_thumb.jpg"
    assert image_compare(fixture, result.payload) == true
  end

  test "process - success for bmp file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "bmp.bmp"})

    result = Application.get_env(:thumbifier, :max_file_size)
    |> Thumbifier.Convert.Processor.process(data)

    assert result.status == "ok"

    fixture = "test/fixtures/files/bmp_thumb.jpg"
    assert image_compare(fixture, result.payload) == true
  end

  test "process - success for pdf file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "pdf.pdf"})

    result = Application.get_env(:thumbifier, :max_file_size)
    |> Thumbifier.Convert.Processor.process(data)

    assert result.status == "ok"

    fixture = "test/fixtures/files/pdf_thumb.jpg"
    assert image_compare(fixture, result.payload) == true
  end
end
