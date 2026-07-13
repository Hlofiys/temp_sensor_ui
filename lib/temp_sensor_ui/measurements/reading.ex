defmodule TempSensorUi.Measurements.Reading do
  use Ecto.Schema
  import Ecto.Changeset

  schema "readings" do
    field :temperature, :float
    field :battery_voltage, :float
    field :battery_charge, :integer
    field :recorded_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:temperature, :battery_voltage, :battery_charge, :recorded_at])
    |> validate_required([:temperature, :battery_voltage, :battery_charge, :recorded_at])
  end
end
