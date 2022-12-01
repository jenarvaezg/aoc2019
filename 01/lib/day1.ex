defmodule Day1 do
  @moduledoc """
  This module implements the solution for advent of code 2019 Day 1, parts 1 and 2
  """

  @spec input_to_int_list :: [list(integer)]
  def input_to_int_list do
    File.read!("input.txt")
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  @spec part1 :: number
  def part1 do
    input_to_int_list()
    |> Enum.map(&fuel_by_weight/1)
    |> Enum.sum
  end

  @spec part2 :: number
  def part2 do
    input_to_int_list()
    |> Enum.map(&fuel_per_module_and_fuel/1)
    |> Enum.sum
  end

  @doc """
  Return the amount of fuel an amount of weight requires

      iex> Day1.fuel_by_weight(12)
      2

      iex> Day1.fuel_by_weight(14)
      2

      iex> Day1.fuel_by_weight(1969)
      654

      iex> Day1.fuel_by_weight(100756)
      33583
  """

  @spec fuel_by_weight(number) :: integer
  def fuel_by_weight(piece_weigth) do
    Float.floor(piece_weigth / 3) - 2
    |> Kernel.trunc
  end

  @doc """
  Returns the amount of fuel for a module, and for its fuel,

  ## Examples

      iex> Day1.fuel_per_module_and_fuel(12)
      2

      iex> Day1.fuel_per_module_and_fuel(1969)
      966

      iex> Day1.fuel_per_module_and_fuel(100756)
      50346

  """
  @spec fuel_per_module_and_fuel(number) :: integer
  def fuel_per_module_and_fuel(piece_weigth) do
    case fuel_by_weight(piece_weigth) do
      fuel when fuel > 0 ->
        fuel + fuel_per_module_and_fuel(fuel)
      _ -> 0
    end
    |> Kernel.trunc
  end
end
