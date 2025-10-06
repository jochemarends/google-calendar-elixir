defmodule Google.CalendarTest do
  use ExUnit.Case
  doctest Google.Calendar

  alias Google.Calendar.Event

  test "greets the world" do
    {:ok, token} = Goth.fetch(Google.Calendar.Goth)
    client = Google.Calendar.client(token.token)

    event = %Event{
      start: DateTime.utc_now() |> DateTime.add(60, :second),
      end: DateTime.utc_now() |> DateTime.add(3600, :second)
    }
  end
end
