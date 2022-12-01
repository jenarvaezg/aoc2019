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


  @spec part1 :: [integer]
  def part1 do
    input_to_int_list()
    |> set_initial_values(12, 2)
    |> process_program
  end

  @spec part2 :: number
  def part2 do
    program = input_to_int_list()
    target = 19690720
    {noun, verb} = find_target_noun_and_verb(program, target)

    100 * noun + verb
  end


  @doc """
    Given a program and a target value for position 0, finds noun and verb which
    would yield that value

    Examples:
    iex> Day2.find_target_noun_and_verb([1, 1, 0, 0, 99], 2)
    {1, 1}

    iex> Day2.find_target_noun_and_verb([2, 1, 0, 0, 99], 2)
    {1, 2}

  """
  @spec find_target_noun_and_verb([integer], integer) :: {integer, integer}
  def find_target_noun_and_verb(program, target) do
    for(noun <- 1..100, verb <- 1..100, do: {noun, verb})
    |> Enum.find(fn {noun, verb} ->
      program
      |> set_initial_values(noun, verb)
      |> process_program
      |> Enum.at(0) == target
    end)
  end


  @doc """
    Sets the initial value for a program, replacing the second and third argument for the input

    Examples:
    iex> Day2.set_initial_values([1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50], 1, 2)
    [1, 1, 2, 3, 2, 3, 11, 0, 99, 30, 40, 50]

    iex> Day2.set_initial_values([1, 1, 1, 4, 99, 5, 6, 0, 99], 4, 5)
    [1, 4, 5, 4, 99, 5, 6, 0, 99]

  """
  @spec set_initial_values([integer], integer, integer) :: [integer]
  def set_initial_values(program, first, second) do
    program
    |> List.replace_at(1, first)
    |> List.replace_at(2, second)
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
