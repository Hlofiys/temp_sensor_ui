defmodule TempSensorUi.MeasurementsTest do
  use TempSensorUi.DataCase

  alias TempSensorUi.Measurements

  describe "readings" do
    alias TempSensorUi.Measurements.Reading

    import TempSensorUi.MeasurementsFixtures

    @invalid_attrs %{temperature: nil, battery_voltage: nil, battery_charge: nil, recorded_at: nil}

    test "list_readings/0 returns all readings" do
      reading = reading_fixture()
      assert Measurements.list_readings() == [reading]
    end

    test "get_reading!/1 returns the reading with given id" do
      reading = reading_fixture()
      assert Measurements.get_reading!(reading.id) == reading
    end

    test "create_reading/1 with valid data creates a reading" do
      valid_attrs = %{temperature: 120.5, battery_voltage: 120.5, battery_charge: 42, recorded_at: ~U[2026-07-12 15:22:00Z]}

      assert {:ok, %Reading{} = reading} = Measurements.create_reading(valid_attrs)
      assert reading.temperature == 120.5
      assert reading.battery_voltage == 120.5
      assert reading.battery_charge == 42
      assert reading.recorded_at == ~U[2026-07-12 15:22:00Z]
    end

    test "create_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Measurements.create_reading(@invalid_attrs)
    end

    test "update_reading/2 with valid data updates the reading" do
      reading = reading_fixture()
      update_attrs = %{temperature: 456.7, battery_voltage: 456.7, battery_charge: 43, recorded_at: ~U[2026-07-13 15:22:00Z]}

      assert {:ok, %Reading{} = reading} = Measurements.update_reading(reading, update_attrs)
      assert reading.temperature == 456.7
      assert reading.battery_voltage == 456.7
      assert reading.battery_charge == 43
      assert reading.recorded_at == ~U[2026-07-13 15:22:00Z]
    end

    test "update_reading/2 with invalid data returns error changeset" do
      reading = reading_fixture()
      assert {:error, %Ecto.Changeset{}} = Measurements.update_reading(reading, @invalid_attrs)
      assert reading == Measurements.get_reading!(reading.id)
    end

    test "delete_reading/1 deletes the reading" do
      reading = reading_fixture()
      assert {:ok, %Reading{}} = Measurements.delete_reading(reading)
      assert_raise Ecto.NoResultsError, fn -> Measurements.get_reading!(reading.id) end
    end

    test "change_reading/1 returns a reading changeset" do
      reading = reading_fixture()
      assert %Ecto.Changeset{} = Measurements.change_reading(reading)
    end
  end
end
