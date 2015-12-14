defmodule TypesTest do
  use Thumbifier.ConnCase

  test "is_basic_image?" do
    assert Thumbifier.Convert.Types.is_basic_image?("image/jpg") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/pjpeg") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/jpeg") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/jpeg") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/gif") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/png") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/bmp") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/x-bmp") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/x-bitmap") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/x-xbitmap") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/x-win-bitmap") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/x-windows-bmp") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/ms-bmp") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/x-ms-bmp") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/tif") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/x-tif") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/tiff") == true
    assert Thumbifier.Convert.Types.is_basic_image?("image/x-tiff") == true
  end

  test "is_pdf?" do
    assert Thumbifier.Convert.Types.is_pdf?("application/pdf") == true
  end

  test "is_psd?" do
    assert Thumbifier.Convert.Types.is_psd?("image/photoshop") == true
    assert Thumbifier.Convert.Types.is_psd?("image/x-photoshop") == true
    assert Thumbifier.Convert.Types.is_psd?("image/psd") == true
    assert Thumbifier.Convert.Types.is_psd?("image/vnd.adobe.photoshop") == true
    assert Thumbifier.Convert.Types.is_psd?("application/photoshop") == true
    assert Thumbifier.Convert.Types.is_psd?("application/psd") == true
  end

  test "is_website?" do
    assert Thumbifier.Convert.Types.is_website?("website") == true
  end

  test "is_supported?" do
    assert Thumbifier.Convert.Types.is_supported?("image/photoshop") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-photoshop") == true
    assert Thumbifier.Convert.Types.is_supported?("image/psd") == true
    assert Thumbifier.Convert.Types.is_supported?("image/vnd.adobe.photoshop") == true
    assert Thumbifier.Convert.Types.is_supported?("application/photoshop") == true
    assert Thumbifier.Convert.Types.is_supported?("application/psd") == true
    assert Thumbifier.Convert.Types.is_supported?("application/pdf") == true
    assert Thumbifier.Convert.Types.is_supported?("image/jpg") == true
    assert Thumbifier.Convert.Types.is_supported?("image/pjpeg") == true
    assert Thumbifier.Convert.Types.is_supported?("image/jpeg") == true
    assert Thumbifier.Convert.Types.is_supported?("image/jpeg") == true
    assert Thumbifier.Convert.Types.is_supported?("image/gif") == true
    assert Thumbifier.Convert.Types.is_supported?("image/png") == true
    assert Thumbifier.Convert.Types.is_supported?("image/bmp") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-bmp") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-bitmap") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-xbitmap") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-win-bitmap") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-windows-bmp") == true
    assert Thumbifier.Convert.Types.is_supported?("image/ms-bmp") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-ms-bmp") == true
    assert Thumbifier.Convert.Types.is_supported?("image/tif") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-tif") == true
    assert Thumbifier.Convert.Types.is_supported?("image/tiff") == true
    assert Thumbifier.Convert.Types.is_supported?("image/x-tiff") == true
    assert Thumbifier.Convert.Types.is_supported?("website") == true
  end

  test "all" do
    expected =
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
        "image/x-tiff",
        "application/pdf",
        "image/photoshop",
        "image/x-photoshop",
        "image/psd",
        "image/vnd.adobe.photoshop",
        "application/photoshop",
        "application/psd",
        "video/x-ms-asf",
        "video/x-ms-wmv",
        "video/msvideo",
        "video/x-msvideo",
        "video/mpeg",
        "video/x-mpeg",
        "video/mp4",
        "website"
      ]

    assert Thumbifier.Convert.Types.all == expected
  end
end
