defmodule TempSensorUi.MqttListener do
  # Use the Tortoise Handler behaviour
  use Tortoise311.Handler

  require Logger
  # We alias our Context so we can call it easily without typing the full name
  alias TempSensorUi.Measurements

  def init(_args) do
    {:ok, %{}}
  end

  def connection(status, state) do
    Logger.info("MQTT Connection status: #{inspect(status)}")
    {:ok, state}
  end

  def subscription(status, state) do
    Logger.info("MQTT Subscription status: #{inspect(status)}")
    {:ok, state}
  end

  # Tortoise splits the topic string into a list.
  # E.g., "device/sensor1" becomes ["device", "sensor1"]
  # UPDATE THIS to match your actual MQTT topic!
  def handle_message(["hangar", "sensor1"], payload, state) do
    Logger.info("Received MQTT message: #{payload}")

    # Phoenix comes with 'Jason' installed for JSON parsing.
    # We pattern match the result. If it's {:ok, map}, it succeeded.
    case Jason.decode(payload) do
      {:ok, data} ->
        # We extract the JSON data and build the map for our DB
        attrs = %{
          temperature: data["temp_c"],
          battery_voltage: data["battery_v"],
          battery_charge: data["battery_pct"],
          recorded_at: DateTime.utc_now()
        }

        # Save it to the database!
        case Measurements.create_reading(attrs) do
          {:ok, _reading} ->
            Logger.info("Successfully saved reading to DB!")
          {:error, changeset} ->
            Logger.error("Failed to save: #{inspect(changeset.errors)}")
        end

      {:error, _} ->
        Logger.error("Failed to parse JSON payload")
    end

    {:ok, state}
  end

  # A catch-all for any topics we haven't explicitly pattern-matched above
  def handle_message(topic, _payload, state) do
    Logger.info("Unhandled topic: #{inspect(topic)}")
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end
end
