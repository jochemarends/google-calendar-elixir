defmodule Google.Calendar.Event do
  alias Google.Calendar
  alias Google.Calendar.Channel

  @type t() :: %__MODULE__{
    id: String.t() | nil,
    created: DateTime.t(),
    start: DateTime.t(),
    end: DateTime.t()
  }

  defstruct [:id, :created, :start, :end]

  @spec encode(t()) :: map()
  def encode(event) do
    event
    |> Map.from_struct()
    |> Map.update!(:start, &encode_time/1)
    |> Map.update!(:end, &encode_time/1)
    |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end
  
  @spec encode_time(DateTime.t()) :: map()
  defp encode_time(dt) do
    %{
      "dateTime" => DateTime.to_iso8601(dt)
    }
  end

  @spec decode!(map()) :: t()
  def decode!(json) do
    %__MODULE__{
      id: Map.get(json, "id"),
      created: decode_datetime!(Map.get(json, "created")),
      start: decode_time!(Map.get(json, "start")),
      end: decode_time!(Map.get(json, "end"))
    }
  end

  @spec decode_time!(map()) :: DateTime.t()
  defp decode_time!(%{"dateTime" => dt}) do
    decode_datetime!(dt)
  end

  @spec decode_datetime!(String.t()) :: DateTime.t()
  defp decode_datetime!(s) do
    {:ok, datetime, _offset} = DateTime.from_iso8601(s)
    datetime
  end

  @spec insert!(Calendar.client(), String.t(), t()) :: t()
  def insert!(client, calendar_id, event) do
    client
    |> Req.post!(url: "/calendars/#{calendar_id}/events", json: encode(event))
    |> then(&decode!(&1.body))
  end

  @type list_result :: %{
    items: [Event.t()],
    next_page_token: String.t() | nil,
    next_sync_token: String.t()
  }

  @spec list!(Calendar.client(), String.t(), keyword()) :: list_result()
  def list!(client, calendar_id, params \\ []) do
    params = Recase.Enumerable.convert_keys(params, &Recase.to_camel/1)

    json =
      client
      |> Req.get!(url: "/calendars/#{calendar_id}/events", params: params)
      |> then(& &1.body)

    %{
      items: Enum.map(json["items"], &decode!/1),
      next_page_token: json["nextPageToken"],
      next_sync_token: json["nextSyncToken"]
    }
  end

  @spec watch!(Calendar.client(), String.t(), keyword()) :: Channel.t()
  def watch!(client, calendar_id, params \\ []) do
    params = Recase.Enumerable.convert_keys(params, &Recase.to_camel/1)
      |> Enum.into(%{})

    json =
      client
      |> Req.post!(url: "/calendars/#{calendar_id}/events/watch", json: params)
      |> then(& &1.body)

    {millis, rest} = Integer.parse(json["expiration"])
    dt = DateTime.from_unix!(millis, :milliseconds)

    %Channel{
      id: json["id"],
      resource_id: json["resourceId"],
      expiration_time: dt
    }
  end
end
