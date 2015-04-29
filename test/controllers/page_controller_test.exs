defmodule Thumbifier.PageControllerTest do
  use Thumbifier.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert conn.resp_body =~ "Thumbifier"
  end
end
