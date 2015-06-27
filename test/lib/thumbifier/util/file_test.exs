defmodule FileTest do
  use Thumbifier.ConnCase

  setup do
    fixture_path = "test/fixtures/files/"
    {:ok, fixture_path: fixture_path}
  end

  test "mime_type - returns error for invalid file_path" do
    file_path = "invalid_path/to_file.pdf"
    assert Thumbifier.Util.File.mime_type(file_path) == {:error, file_path <> " file not found"}
  end

  test "mime_type - returns file mime-type for pdf", %{fixture_path: fixture_path} do
    file_path = fixture_path <> "pdf.pdf"
    assert Thumbifier.Util.File.mime_type(file_path) == {:ok, "application/pdf"}
  end
end
