defmodule ConverterTest do
  use Thumbifier.ConnCase

  setup do
    fixture_path = System.cwd <> "/test/fixtures/files/"
    {:ok, fixture_path: fixture_path}
  end

  test "resize - returns error when given file is not found" do
    file_path = "invalid_path/invalid_file.pdf"
    assert Thumbifier.Convert.Converter.resize(file_path, 72, "100x100") == {:error, file_path <> " not found"}
  end

  test "resize - outputs jpg at the new size and quality", %{fixture_path: fixture_path} do
    file_path = fixture_path <> "pdf.pdf"
    results = Thumbifier.Convert.Converter.resize(file_path, 72, "100x100")
    output_path = elem(results, 1)

    assert File.exists?(output_path) == true
    File.rm(output_path)
  end

  test "pdf - outputs a jpg from a source pdf for the given page", %{fixture_path: fixture_path} do
    file_path = fixture_path <> "pdf.pdf"
    results = Thumbifier.Convert.Converter.from_pdf(file_path, 72, "100x100", 1)
    output_path = elem(results, 1)

    assert File.exists?(output_path) == true
    File.rm(output_path)
  end

  test "psd - outputs a jpg from a source psd for the given page", %{fixture_path: fixture_path} do
    file_path = fixture_path <> "psd.psd"
    results = Thumbifier.Convert.Converter.from_psd(file_path, 72, "100x100", 1)
    output_path = elem(results, 1)

    assert File.exists?(output_path) == true
    File.rm(output_path)
  end

  test "video - outputs a jpg from a source video for the given frame", %{fixture_path: fixture_path} do
    file_path = fixture_path <> "mp4.mp4"
    results = Thumbifier.Convert.Converter.from_video(file_path, 72, "100x100", "00:00:03")
    output_path = elem(results, 1)

    assert File.exists?(output_path) == true
    File.rm(output_path)
  end

  test "website - outputs a jpg from a source website" do
    file_path = "http://www.sysdia.com"
    results = Thumbifier.Convert.Converter.from_website(file_path, 72, "100x100")
    output_path = elem(results, 1)

    assert File.exists?(output_path) == true
    File.rm(output_path)
  end

  test "document - outputs a jpg from a source office document for the given page", %{fixture_path: fixture_path} do
    file_path = fixture_path <> "doc.doc"
    results = Thumbifier.Convert.Converter.from_document(file_path, 72, "100x100", "1")
    output_path = elem(results, 1)

    assert File.exists?(output_path) == true
    File.rm(output_path)
  end

  test "spreadsheet - outputs a jpg from a source office spreadsheet for the given page", %{fixture_path: fixture_path} do
    file_path = fixture_path <> "xls.xls"
    results = Thumbifier.Convert.Converter.from_spreadsheet(file_path, 72, "100x100", "1")
    output_path = elem(results, 1)

    assert File.exists?(output_path) == true
    File.rm(output_path)
  end

  test "presentation - outputs a jpg from a source office presentation for the given page", %{fixture_path: fixture_path} do
    file_path = fixture_path <> "ppt.ppt"
    results = Thumbifier.Convert.Converter.from_presentation(file_path, 72, "100x100", "1")
    output_path = elem(results, 1)

    assert File.exists?(output_path) == true
    File.rm(output_path)
  end
end
