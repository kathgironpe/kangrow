defmodule KanGrowWeb.PageController do
  use KanGrowWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
