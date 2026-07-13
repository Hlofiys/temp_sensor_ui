defmodule TempSensorUi.Measurements do
  @moduledoc """
  The Measurements context.
  """

  import Ecto.Query, warn: false
  alias TempSensorUi.Repo
  alias TempSensorUi.Measurements.Reading

  # 1. New function to fetch readings from the last X minutes
  def list_readings_by_range(minutes) when is_integer(minutes) do
    time_ago = DateTime.add(DateTime.utc_now(), -minutes, :minute)

    # This is an Ecto Query! It is highly secure against SQL injection.
    Reading
    |> where([r], r.recorded_at >= ^time_ago)
    |> order_by([r], desc: r.recorded_at)
    |> Repo.all()
  end

  # Fallback for "all time"
  def list_readings_by_range("all") do
    Reading
    |> order_by([r], desc: r.recorded_at)
    |> Repo.all()
  end

  # 2. Update create_reading to broadcast a message via PubSub
  def create_reading(attrs \\ %{}) do
    %Reading{}
    |> Reading.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, reading} ->
        # If successful, shout it to anyone listening on the "readings" channel!
        Phoenix.PubSub.broadcast(TempSensorUi.PubSub, "readings", {:new_reading, reading})
        {:ok, reading}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
