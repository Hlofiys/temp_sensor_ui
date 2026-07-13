defmodule TempSensorUi.Repo do
  use Ecto.Repo,
    otp_app: :temp_sensor_ui,
    adapter: Ecto.Adapters.SQLite3
end
