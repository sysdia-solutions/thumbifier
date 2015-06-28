defmodule Thumbifier.Convert.Processor do
  def process(max_file_size, data) do
    Thumbifier.Util.URI.details(data["media_url"])
    |> process_remote_file_details(data, max_file_size)
  end

  defp process_remote_file_details({:error, message}, data, _max_file_size) do
    process_callback(data["callback_url"], "error", data["response_id"], data["personal_reference"], "[0001] " <> message)
  end

  defp process_remote_file_details({:ok, details}, data, max_file_size) do
    details[:size]
    |> under_limit?(max_file_size)
    |> process_remote_file(details[:type], data)
  end

  defp under_limit?(size, max_file_size) do
    size < max_file_size
  end

  defp process_remote_file(false, _type, data) do
    process_callback(data["callback_url"], "error", data["response_id"], data["personal_reference"], "[0002] File limit exceeded")
  end

  defp process_remote_file(true, :file, data) do
    source = System.tmp_dir! <> "/" <> Ecto.UUID.generate
    Thumbifier.Util.URI.download(data["media_url"], source)

    mime_type = Thumbifier.Util.File.mime_type(source)

    elem(mime_type, 1)
    |> process_convert(source, data)

    File.rm(source)
  end

  defp process_remote_file(true, :site, data) do
    process_convert("website", data["media_url"], data)
  end

  defp process_convert(mime_type, source, data) do
    case mime_type do
      "application/pdf" ->
         Thumbifier.Convert.Converter.from_pdf(source, data["quality"], data["dimensions"], data["page"])
      _ ->
         {:error, "mime-type " <> mime_type <> " not supported"}
    end
    |> process_output(data)
  end

  defp process_output({:error, message}, data) do
    process_callback(data["callback_url"], "error", data["response_id"], data["personal_reference"], "[0003] " <> message)
  end

  defp process_output({:ok, output}, data) do
    encoded = output
              |> File.read!
              |> Base.encode64

    process_callback(data["callback_url"], "success", data["response_id"], data["personal_reference"], encoded)
    File.rm(output)
  end

  defp process_callback(callback_url, status, response_id, personal_reference, payload) do
    { :form,
      [
        status: status,
        response_id: response_id,
        personal_reference: personal_reference,
        payload: payload
      ]
    }
    |> Thumbifier.Util.URI.post(callback_url)
  end
end
