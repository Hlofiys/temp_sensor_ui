defmodule TempSensorUiWeb.DashboardLive do
  use TempSensorUiWeb, :live_view
  alias TempSensorUi.Measurements

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(TempSensorUi.PubSub, "readings")
    end

    readings = Measurements.list_readings_by_range("all")

    # 1. ASSIGN HERE FOR INITIAL PAGE LOAD
    {:ok, assign(socket,
      readings: readings,
      chart_data: prepare_chart_data(readings),
      current_filter: "all"
    )}
  end

  @impl true
  def handle_info({:new_reading, reading}, socket) do
    # Because you are sorting descending (newest first),
    # we prepend the new reading to the top of the list!
    new_readings = [reading | socket.assigns.readings]

    # 2. ASSIGN HERE FOR REAL-TIME BACKGROUND UPDATES
    {:noreply, assign(socket,
      readings: new_readings,
      chart_data: prepare_chart_data(new_readings)
    )}
  end

  @impl true
  def handle_event("filter_time", %{"minutes" => minutes_str}, socket) do
    filter_val = if minutes_str == "all", do: "all", else: String.to_integer(minutes_str)
    readings = Measurements.list_readings_by_range(filter_val)

    # 3. ASSIGN HERE FOR BUTTON CLICKS
    {:noreply, assign(socket,
      readings: readings,
      chart_data: prepare_chart_data(readings),
      current_filter: minutes_str
    )}
  end

  # Helper to prepare data for the chart
  defp prepare_chart_data(readings) do
    readings
    # We reverse it because the table is descending, but charts must draw left-to-right (chronological)
    |> Enum.reverse()
    |> Enum.map(fn r ->
      %{
        x: DateTime.to_iso8601(r.recorded_at),
        y: r.temperature
      }
    end)
    |> Jason.encode!()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8 max-w-6xl mx-auto">
      <h1 class="text-3xl font-bold mb-6">Temperature Dashboard</h1>

      <!-- Filter Buttons -->
      <div class="join mb-6">
        <button phx-click="filter_time" phx-value-minutes="60" class={"join-item btn " <> if @current_filter == "60", do: "btn-active", else: ""}>Last Hour</button>
        <button phx-click="filter_time" phx-value-minutes="1440" class={"join-item btn " <> if @current_filter == "1440", do: "btn-active", else: ""}>Last 24 Hours</button>
        <button phx-click="filter_time" phx-value-minutes="all" class={"join-item btn " <> if @current_filter == "all", do: "btn-active", else: ""}>All Time</button>
      </div>

      <!-- THE CHART CONTAINER -->
      <div class="bg-base-100 shadow-xl rounded-lg p-4 mb-8">
        <div id="temperature-chart" phx-hook="TemperatureChart" phx-update="ignore" data-series={@chart_data}></div>
      </div>

      <!-- The Table -->
      <div class="overflow-x-auto bg-base-100 shadow-xl rounded-lg">
        <table class="table w-full">
          <thead>
            <tr class="bg-base-200">
              <th>Time</th>
              <th>Temp (°C)</th>
              <th>Battery (V)</th>
              <th>Battery (%)</th>
            </tr>
          </thead>
          <tbody>
            <%= for reading <- @readings do %>
              <tr class="hover">
                <td><%= Calendar.strftime(reading.recorded_at, "%Y-%m-%d %H:%M:%S") %></td>
                <td><%= reading.temperature %></td>
                <td><%= reading.battery_voltage %></td>
                <td>
                  <span class={"badge " <> if reading.battery_charge < 20, do: "badge-error", else: "badge-success"}>
                    <%= reading.battery_charge %>%
                  </span>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
