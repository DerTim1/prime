defmodule PrimWeb.PageController do
  use PrimWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
