defmodule Google.Calendar do
  @moduledoc """
  Documentation for `Google.Calendar`.
  """

  @base_url "https://www.googleapis.com/calendar/v3/"

  @type client :: Req.Request.t()

  @spec client(String.t()) :: client()
  def client(token) do
    headers = %{
      "Authorization" => "Bearer #{token}",
      "Accept" => "application/json"
    }
    Req.new(base_url: @base_url, headers: headers)
  end
end
