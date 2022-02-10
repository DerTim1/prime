defmodule PrimWeb.ShowLiveControllerTest do
  use PrimWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "\n  -\n"
  end
end
