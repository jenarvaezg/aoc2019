defmodule Day5 do
  @moduledoc """
  Implementation for advent of code Day 5
  """

  @spec input_to_int_list :: [list(integer)]
  defp input_to_int_list do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @spec main :: [integer]
  def main do
    input_to_int_list()
    |> process_program
  end

  @doc """
    Processes a full program, instruction by instruction, returns the final program
    after processing all instructions
  """
  @spec process_program(list(integer), integer) :: list(integer)
  def process_program(program, pointer \\ 0) do
    instruction = parse_instruction(Enum.at(program, pointer))

    case process_instruction(instruction, program, pointer) do
      {program, -1} -> program
      {program, next_pointer} -> process_program(program, next_pointer)
    end
  end

  @spec process_instruction(Day5.Instruction.t(), list(integer), integer) ::
          {list(integer), integer}
  def process_instruction(instruction, program, pointer) do
    case instruction.opcode do
      1 -> process_sum_instruction(instruction, program, pointer)
      2 -> process_mul_instruction(instruction, program, pointer)
      3 -> process_input_instruction(instruction, program, pointer)
      4 -> process_output_instruction(instruction, program, pointer)
      5 -> process_jump_if_true_instruction(instruction, program, pointer)
      6 -> process_jump_if_false_instruction(instruction, program, pointer)
      7 -> process_less_than_instruction(instruction, program, pointer)
      8 -> process_equals_instruction(instruction, program, pointer)
      99 -> process_halt_instruction(instruction, program, pointer)
    end
  end

  @spec process_sum_instruction(Day5.Instruction.t(), [integer], integer) :: {[integer], integer}
  def process_sum_instruction(instruction, program, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)
    target = Enum.at(program, pointer + 3)
    {List.replace_at(program, target, a + b), pointer + 4}
  end

  @spec process_mul_instruction(Day5.Instruction.t(), [integer], integer) :: {[integer], integer}
  def process_mul_instruction(instruction, program, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)
    target = Enum.at(program, pointer + 3)
    {List.replace_at(program, target, a * b), pointer + 4}
  end

  @spec process_input_instruction(Day5.Instruction.t(), [integer], integer) ::
          {[integer], integer}
  def process_input_instruction(_, program, pointer) do
    input =
      IO.gets("Input? ")
      |> String.trim()
      |> String.to_integer()

    target = Enum.at(program, pointer + 1)
    {List.replace_at(program, target, input), pointer + 2}
  end

  @spec process_output_instruction(Day5.Instruction.t(), [integer], integer) ::
          {[integer], integer}
  def process_output_instruction(_, program, pointer) do
    target = Enum.at(program, pointer + 1)
    IO.puts(Enum.at(program, target))
    {program, pointer + 2}
  end

  @spec process_jump_if_true_instruction(Day5.Instruction.t(), [integer], integer) ::
          {[integer], integer}
  def process_jump_if_true_instruction(instruction, program, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)

    if a != 0 do
      {program, b}
    else
      {program, pointer + 3}
    end
  end

  @spec process_jump_if_false_instruction(Day5.Instruction.t(), [integer], integer) ::
          {[integer], integer}
  def process_jump_if_false_instruction(instruction, program, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)

    if a == 0 do
      {program, b}
    else
      {program, pointer + 3}
    end
  end

  @spec process_less_than_instruction(Day5.Instruction.t(), [integer], integer) ::
          {[integer], integer}
  def process_less_than_instruction(instruction, program, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)
    target = Enum.at(program, pointer + 3)

    if a < b do
      {List.replace_at(program, target, 1), pointer + 4}
    else
      {List.replace_at(program, target, 0), pointer + 4}
    end
  end

  @spec process_equals_instruction(Day5.Instruction.t(), [integer], integer) ::
          {[integer], integer}
  def process_equals_instruction(instruction, program, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)
    target = Enum.at(program, pointer + 3)

    if a == b do
      {List.replace_at(program, target, 1), pointer + 4}
    else
      {List.replace_at(program, target, 0), pointer + 4}
    end
  end

  @spec process_halt_instruction(Day5.Instruction.t(), [integer], integer) :: {[integer], -1}
  def process_halt_instruction(_, program, _) do
    {program, -1}
  end

  @spec get_value(0 | 1, integer, [integer]) :: any
  def get_value(0, position, program) do
    Enum.at(program, position)
  end

  def get_value(1, value, _) do
    value
  end

  @spec parse_instruction(integer) :: Day5.Instruction.t()
  def parse_instruction(instruction) do
    [_, a, b, c | de] = Integer.digits(instruction + 100_000)

    %Day5.Instruction{
      opcode: Integer.undigits(de),
      first_mode: c,
      second_mode: b,
      third_mode: a
    }
  end
end
