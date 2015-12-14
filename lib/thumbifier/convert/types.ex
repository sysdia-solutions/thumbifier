defmodule Thumbifier.Convert.Types do
  def all() do
    basic_image
    ++ pdf
    ++ psd
    ++ video
    ++ website
    ++ document
    ++ spreadsheet
    ++ presentation
  end

  def is_supported?(type) do
    type in all
  end

  def is_basic_image?(type) do
    type in basic_image
  end

  def is_pdf?(type) do
    type in pdf
  end

  def is_psd?(type) do
    type in psd
  end

  def is_video?(type) do
    type in video
  end

  def is_website?(type) do
    type in website
  end

  def is_document?(type) do
    type in document
  end

  def is_spreadsheet?(type) do
    type in spreadsheet
  end

  def is_presentation?(type) do
    type in presentation
  end

  defp basic_image() do
    [
      "image/jpg",
      "image/pjpeg",
      "image/jpeg",
      "image/gif",
      "image/png",
      "image/bmp",
      "image/x-bmp",
      "image/x-bitmap",
      "image/x-xbitmap",
      "image/x-win-bitmap",
      "image/x-windows-bmp",
      "image/ms-bmp",
      "image/x-ms-bmp",
      "image/tif",
      "image/x-tif",
      "image/tiff",
      "image/x-tiff"
    ]
  end

  defp pdf() do
    [
      "application/pdf"
    ]
  end

  defp psd() do
  [
    "image/photoshop",
    "image/x-photoshop",
    "image/psd",
    "image/vnd.adobe.photoshop",
    "application/photoshop",
    "application/psd"
  ]
  end

  defp video() do
    [
      "video/x-ms-asf",
      "video/x-ms-wmv",
      "video/msvideo",
      "video/x-msvideo",
      "video/mpeg",
      "video/x-mpeg",
      "video/mp4"
    ]
  end

  defp website() do
    [
      "website"
    ]
  end

  defp document() do
    [
      "application/msword",
      "application/vnd.oasis.opendocument.text",
      "application/x-vnd.oasis.opendocument.text"
    ]
  end

  defp spreadsheet() do
    [
      "application/vnd.ms-excel",
      "application/vnd.oasis.opendocument.spreadsheet",
      "application/x-vnd.oasis.opendocument.spreadsheet",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    ]
  end

  defp presentation() do
    [
      "application/vnd.ms-powerpoint",
      "application/vnd.oasis.opendocument.presentation",
      "application/x-vnd.oasis.opendocument.presentation"
    ]
  end
end
