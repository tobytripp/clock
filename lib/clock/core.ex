defmodule Clock.Core do
  defstruct ~w[hours minutes seconds]a
  @brightness 0x060

  def new(%{hour: hours, minute: minutes, second: seconds}) do
    %__MODULE__{
      hours:   hours,
      minutes: minutes,
      seconds: seconds
    }
  end

  def to_leds(clock, format \\ :bytes) do
    [
    (clock.minutes |> padded_bits),
    (0 |> padded_bits),
    (clock.hours   |> padded_bits),
    (clock.seconds |> padded_bits)
    ]
    |> List.flatten
    |> formatter(format)
  end

  def padded_bits(number, total_length \\ 6) do
    bits = Integer.digits(number, 2)
    padding = List.duplicate(0, total_length - length(bits))
    padding ++ bits
  end

  defp formatter(list, :none),   do: list
  defp formatter(list, :bytes),  do: to_bytes(list)
  defp formatter(list, :pretty), do: pretty(list)

  defp to_bytes(list) do
    for bit <- Enum.reverse(list), into: <<>>,  do: to_byte(bit)
  end

  defp to_byte(0), do: <<0::12>>
  defp to_byte(_), do: <<@brightness::12>>

  defp to_pretty_byte(0), do: "-"
  defp to_pretty_byte(_), do: "*"

  defp pretty(list) do
    for bit <- list, into: "", do: to_pretty_byte(bit)
  end
end
