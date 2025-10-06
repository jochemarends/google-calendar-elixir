defmodule Google.Calendar.Channel do
  @type t() :: %__MODULE__{
    id: String.t(),
    resource_id: String.t(),
    expiration_time: DateTime.t()
  }

  defstruct [:id, :resource_id, :expiration_time] 
end
