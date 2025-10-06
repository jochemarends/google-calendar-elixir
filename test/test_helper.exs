ExUnit.start()

service_account = 
  System.fetch_env!("GOOGLE_SERVICE_ACCOUNT_PATH")
  |> File.read!()
  |> Jason.decode!()

{:ok, _pid} = Goth.start_link(
  name: Google.Calendar.Goth,
  source: {:service_account,
    service_account,
    scopes: [
      "https://www.googleapis.com/auth/calendar",
      "https://www.googleapis.com/auth/calendar.calendarlist"
    ]}
)
