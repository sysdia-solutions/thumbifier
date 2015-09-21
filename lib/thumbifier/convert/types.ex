defmodule Thumbifier.Convert.Types do
  def all() do
    basic_image
    ++ pdf
    ++ psd
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
end
