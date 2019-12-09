defmodule Day9 do
  @moduledoc """
  Implementation for advent of code Day 7
  """

  @spec input_to_int_list :: [list(integer)]
  defp input_to_int_list do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part1 do
    input_to_int_list()
    |> Day9.Intcode.process_program([1])
  end

  def part2 do
    input_to_int_list()
    |> Day9.Intcode.process_program([2])
  end

end
