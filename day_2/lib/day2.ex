defmodule Day2 do
  @moduledoc """
  Implementation for advent of code Day 2
  """

  @spec input_to_int_list :: [list(integer)]
  def input_to_int_list do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end


  def main do
    input_to_int_list()
    |> process_program
  end


  @doc """
    Processes a full program, instruction by instruction, returns the final program
    after processing all instructions

    Examples:
    iex> Day2.process_program([1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50])
    [3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50]

    iex> Day2.process_program([1, 1, 1, 4, 99, 5, 6, 0, 99])
    [30, 1, 1, 4, 2, 5, 6, 0, 99]
  """
  @spec process_program(list(integer), integer) :: list(integer)
  def process_program(program, pointer \\ 0) do
    instruction = Enum.slice(program, pointer, 4)
    case process_instruction(instruction, program) do
      {program, :continue} -> process_program(program, pointer + 4)
      {program, :done} -> program
    end
  end

  @doc """
    Processes an instruction and returns the new program, and wether it should stop or continue

    Examples:
    iex> Day2.process_instruction([1, 0, 0, 0], [1, 0, 0, 0, 99])
    {[2, 0, 0, 0, 99], :continue}

    iex> Day2.process_instruction([99], [2, 0, 0, 0, 99])
    {[2, 0, 0, 0, 99], :done}

    iex> Day2.process_instruction([2, 3, 0, 3], [2, 3, 0, 3, 99])
    {[2, 3, 0, 6, 99], :continue}

    iex> Day2.process_instruction([2, 4, 4, 5], [2, 4, 4, 5, 99, 0])
    {[2, 4, 4, 5, 99, 9801], :continue}

    iex> Day2.process_instruction([1, 1, 1, 4], [1, 1, 1, 4, 99, 5, 6, 0, 99])
    {[1, 1, 1, 4, 2, 5, 6, 0, 99], :continue}
  """
  @spec process_instruction(list(integer), list(integer)) :: {list(integer), :continue | :done}
  def process_instruction(instruction, program) do
    case instruction do
      [99 | _] ->
        {program, :done}
      [1, a, b, target] ->
        value = Enum.at(program, a) + Enum.at(program, b)
        {List.replace_at(program, target, value), :continue}
      [2, a, b, target] ->
        value = Enum.at(program, a) * Enum.at(program, b)
        {List.replace_at(program, target, value), :continue}
    end
  end
end
