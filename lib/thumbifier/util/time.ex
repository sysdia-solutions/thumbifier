defmodule Thumbifier.Util.Time do
  use Timex

  def timex_from_ecto(date) do
    Ecto.DateTime.to_erl(date)
    |> Date.from
  end

  def ecto_now() do
    Ecto.DateTime.local
  end

  def ecto_shift(ecto_datetime, amount) do
    timex_from_ecto(ecto_datetime)
    |> Date.shift(amount)
    |> timex_to_tuple
    |> Ecto.DateTime.from_erl
  end

  defp timex_to_tuple(date) do
    {
      {date.year, date.month, date.day},
      {date.hour, date.minute, date.second}
    }
  end
end
