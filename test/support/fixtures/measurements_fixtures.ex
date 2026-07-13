defmodule TempSensorUi.MeasurementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TempSensorUi.Measurements` context.
  """

  @doc """
  Generate a reading.
  """
  def reading_fixture(attrs \\ %{}) do
    {:ok, reading} =
      attrs
      |> Enum.into(%{
        battery_charge: 42,
        battery_voltage: 120.5,
        recorded_at: ~U[2026-07-12 15:22:00Z],
        temperature: 120.5
      })
      |> TempSensorUi.Measurements.create_reading()

    reading
  end
end
