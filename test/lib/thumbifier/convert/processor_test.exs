defmodule ProcessorTest do
  use Thumbifier.ConnCase
  import Mock

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

  test "process - posts error when provided media_url is too large", %{data: data} do
    with_mock HTTPoison, [post: fn(_data, _callback_url) -> :ok end] do
      Thumbifier.Convert.Processor.process(1, data)

      form = { :form,
        [
          status: "error",
          response_id: data["response_id"],
          personal_reference: data["personal_reference"],
          payload: "[0002] File limit exceeded"
        ]
      }
      assert called HTTPoison.post(data["callback_url"], form)
    end
  end

  test "process - posts error when provided media_url is not supported", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "iff.iff"})
    with_mock HTTPoison, [post: fn(_data, _callback_url) -> :ok end] do
      Application.get_env(:thumbifier, :max_file_size)
      |> Thumbifier.Convert.Processor.process(data)

      form = { :form,
        [
          status: "error",
          response_id: data["response_id"],
          personal_reference: data["personal_reference"],
          payload: "[0003] mime-type application/octet-stream not supported"
        ]
      }
      assert called HTTPoison.post(data["callback_url"], form)
    end
  end

  test "process - success for tiff file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{
      "media_url" => remote_fixtures_path <> "tiff.tiff",
      "dimensions" => "250x250"
      })

    with_mock HTTPoison, [post: fn(_data, _callback_url) -> :ok end] do
      Application.get_env(:thumbifier, :max_file_size)
      |> Thumbifier.Convert.Processor.process(data)

      form = { :form,
        [
          status: "success",
          response_id: data["response_id"],
          personal_reference: data["personal_reference"],
          payload: System.cwd <> "/test/fixtures/files/tiff_thumb.jpg" |> File.read! |> Base.encode64
        ]
      }
      assert called HTTPoison.post(data["callback_url"], form)
    end
  end

  test "process - success for png file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "png.png"})

    with_mock HTTPoison, [post: fn(_data, _callback_url) -> :ok end] do
      Application.get_env(:thumbifier, :max_file_size)
      |> Thumbifier.Convert.Processor.process(data)

      form = { :form,
        [
          status: "success",
          response_id: data["response_id"],
          personal_reference: data["personal_reference"],
          payload: System.cwd <> "/test/fixtures/files/png_thumb.jpg" |> File.read! |> Base.encode64
        ]
      }
      assert called HTTPoison.post(data["callback_url"], form)
    end
  end

  test "process - success for gif file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "gif.gif"})

    with_mock HTTPoison, [post: fn(_data, _callback_url) -> :ok end] do
      Application.get_env(:thumbifier, :max_file_size)
      |> Thumbifier.Convert.Processor.process(data)

      form = { :form,
        [
          status: "success",
          response_id: data["response_id"],
          personal_reference: data["personal_reference"],
          payload: System.cwd <> "/test/fixtures/files/gif_thumb.jpg" |> File.read! |> Base.encode64
        ]
      }
      assert called HTTPoison.post(data["callback_url"], form)
    end
  end

  test "process - success for bmp file format", %{data: data, remote_fixtures_path: remote_fixtures_path} do
    data = Map.merge(data, %{"media_url" => remote_fixtures_path <> "bmp.bmp"})

    with_mock HTTPoison, [post: fn(_data, _callback_url) -> :ok end] do
      Application.get_env(:thumbifier, :max_file_size)
      |> Thumbifier.Convert.Processor.process(data)

      form = { :form,
        [
          status: "success",
          response_id: data["response_id"],
          personal_reference: data["personal_reference"],
          payload: System.cwd <> "/test/fixtures/files/bmp_thumb.jpg" |> File.read! |> Base.encode64
        ]
      }
      assert called HTTPoison.post(data["callback_url"], form)
    end
  end
end
