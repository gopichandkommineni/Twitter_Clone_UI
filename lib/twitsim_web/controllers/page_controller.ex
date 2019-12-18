defmodule TwitsimWeb.PageController do
  use TwitsimWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
