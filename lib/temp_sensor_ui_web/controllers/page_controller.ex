defmodule TempSensorUiWeb.PageController do
  use TempSensorUiWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
