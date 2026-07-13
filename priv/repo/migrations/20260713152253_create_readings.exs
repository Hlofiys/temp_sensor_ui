defmodule TempSensorUi.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :temperature, :float
      add :battery_voltage, :float
      add :battery_charge, :integer
      add :recorded_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
