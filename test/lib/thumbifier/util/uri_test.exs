defmodule URITest do
  use Thumbifier.ConnCase
  import Mock

  setup do
    :ok
  end

  test "valid? - returns true on valid URI" do
    assert Thumbifier.Util.URI.valid?("http://www.pdf.com") == true
    assert Thumbifier.Util.URI.valid?("https://www.pdf.com") == true
    assert Thumbifier.Util.URI.valid?("http://www.pdf.com:81") == true
    assert Thumbifier.Util.URI.valid?("http://www.pdf.com/sub.file") == true
    assert Thumbifier.Util.URI.valid?("http://www.pdf.com/sub/folder/sub.file") == true
    assert Thumbifier.Util.URI.valid?("http://pdf.com/sub/folder/sub.file") == true
    assert Thumbifier.Util.URI.valid?("http://subdomain.pdf.co.uk/sub/folder/sub.file") == true
    assert Thumbifier.Util.URI.valid?("http://subdomain.pdf.longtld/sub/folder/sub.file") == true
    assert Thumbifier.Util.URI.valid?("ftp://pdf.com/pdf.pdf") == true
    assert Thumbifier.Util.URI.valid?("www.pdf.com") == true
  end

  test "valid? - returns false on invalid URI" do
    assert Thumbifier.Util.URI.valid?("") == false
    assert Thumbifier.Util.URI.valid?("pdf") == false
    assert Thumbifier.Util.URI.valid?("pdf/file.pdf") == false
    assert Thumbifier.Util.URI.valid?("http://pdf") == false
    assert Thumbifier.Util.URI.valid?("http://pdf/file.pdf") == false
    assert Thumbifier.Util.URI.valid?("C:\local\file\path\file.pdf") == false
    assert Thumbifier.Util.URI.valid?("/local/file/path/file.pdf") == false
  end

  test "details - displays `file` and associated filesize when file uri given" do
    response = "Spider mode enabled. Check if remote file exists.\n--2015-06-21 06:47:42--  http://www.pdf995.com/samples/pdf.pdf\nResolving www.pdf995.com... 98.139.134.174\nConnecting to www.pdf995.com|98.139.134.174|:80... connected.\nHTTP request sent, awaiting response... 200 OK\nLength: 433994 (424K) [application/pdf]\nRemote file exists.\n\n"

    with_mock Thumbifier.Util.Shell, [wget: fn(_uri) -> response end] do
      uri = "http://www.testsite.com/samples/pdf.pdf"
      assert Thumbifier.Util.URI.details(uri) == {:ok, [size: 433994, type: :file]}
    end
  end

  test "details - displays `site` and associated filesize when website uri given" do
    response = "Spider mode enabled. Check if remote file exists.\n--2015-06-21 06:48:25--  http://www.pdf995.com/\nResolving www.pdf995.com... 98.139.134.174\nConnecting to www.pdf995.com|98.139.134.174|:80... connected.\nHTTP request sent, awaiting response... 200 OK\nLength: 15677 (15K) [text/html]\nRemote file exists and could contain further links,\nbut recursion is disabled -- not retrieving.\n\n"

    with_mock Thumbifier.Util.Shell, [wget: fn(_uri) -> response end] do
      uri = "http://www.testsite.com"
      assert Thumbifier.Util.URI.details(uri) == {:ok, [size: 15677, type: :site]}
    end
  end

  test "details - displays error message on invalid URI" do
    uri = "pdf/file.pdf"
    assert Thumbifier.Util.URI.details(uri) == {:error, uri <> " is not a valid URI"}
  end
end
