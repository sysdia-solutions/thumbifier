defmodule Thumbifier.Convert.Processor do
  def process(max_file_size, data) do
    Thumbifier.Util.URI.details(data["media_url"])
    |> process_remote_file_details(data, max_file_size)
  end

  def callback_payload(%{status: status, payload: payload}, data) do
    { :form,
      [
        status: status,
        response_id: data["response_id"],
        personal_reference: data["personal_reference"],
        payload: payload
      ]
    }
  end

  defp process_remote_file_details({:error, message}, _data, _max_file_size) do
    %{status: "error", payload: "[0001]" <> message}
  end

  defp process_remote_file_details({:ok, details}, data, max_file_size) do
    details[:size]
    |> under_limit?(max_file_size)
    |> process_remote_file(details[:type], data)
  end

  defp under_limit?(size, max_file_size) do
    size < max_file_size
  end

  defp process_remote_file(false, _type, _data) do
    %{status: "error", payload: "[0002] File limit exceeded"}
  end

  defp process_remote_file(true, :file, data) do
    source = System.tmp_dir! <> "/" <> Ecto.UUID.generate
    Thumbifier.Util.URI.download(data["media_url"], source)

    mime_type = Thumbifier.Util.File.mime_type(source)

    result = elem(mime_type, 1)
    |> process_convert(source, data)

    File.rm(source)

    result
  end

  defp process_remote_file(true, :site, data) do
    process_convert("website", data["media_url"], data)
  end

  defp process_convert(mime_type, source, data) do
    cond do
      Thumbifier.Convert.Types.is_basic_image?(mime_type) ->
        Thumbifier.Convert.Converter.resize(source, data["quality"], data["dimensions"])

      Thumbifier.Convert.Types.is_pdf?(mime_type) ->
        Thumbifier.Convert.Converter.from_pdf(source, data["quality"], data["dimensions"], data["page"])

      Thumbifier.Convert.Types.is_psd?(mime_type) ->
        Thumbifier.Convert.Converter.from_pdf(source, data["quality"], data["dimensions"], data["page"])

      Thumbifier.Convert.Types.is_video?(mime_type) ->
        Thumbifier.Convert.Converter.from_video(source, data["quality"], data["dimensions"], data["frame"])

      true ->
        {:error, "mime-type " <> mime_type <> " not supported"}
    end
    |> process_output(data)
  end

  defp process_output({:error, message}, _data) do
    %{status: "error", payload: "[0003] " <> message}
  end

  defp process_output({:ok, output}, _data) do
    encoded = output
              |> File.read!
              |> Base.encode64

    File.rm(output)
    %{status: "ok", payload: encoded}
  end
end
