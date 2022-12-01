defmodule Intcode do
  defstruct opcode: nil, first_mode: nil, second_mode: nil, third_mode: nil

  @doc """
    Processes a full program, instruction by instruction, returns the final program
    after processing all instructions
  """
  def process_program(program, input, pointer \\ 0, relative_base \\ -1)
  def process_program(program, input, 0, -1) do
    program = program ++ List.duplicate(0, 100_000)
    process_program(program, input, 0, 0)
  end
  def process_program(program, input, pointer, relative_base) do
    instruction = parse_instruction(Enum.at(program, pointer))

    case process_instruction(instruction, program, input, pointer, relative_base) do
      {program, _input, -1, relative_base, output, :halt} ->
        {program, output, -1, relative_base}

      {program, _input, next_pointer, relative_base, output, :halt} ->
        # IO.puts(output)
        #process_program(program, input, next_pointer, relative_base)
        {program, output, next_pointer, relative_base}

      {program, input, next_pointer, relative_base, nil, :go} ->
        process_program(program, input, next_pointer, relative_base)
    end
  end

  def process_instruction(instruction, program, input, pointer, relative_base) do
    case instruction.opcode do
      1 -> process_sum_instruction(instruction, program, input, pointer, relative_base)
      2 -> process_mul_instruction(instruction, program, input, pointer, relative_base)
      3 -> process_input_instruction(instruction, program, input, pointer, relative_base)
      4 -> process_output_instruction(instruction, program, input, pointer, relative_base)
      5 -> process_jump_if_true_instruction(instruction, program, input, pointer, relative_base)
      6 -> process_jump_if_false_instruction(instruction, program, input, pointer, relative_base)
      7 -> process_less_than_instruction(instruction, program, input, pointer, relative_base)
      8 -> process_equals_instruction(instruction, program, input, pointer, relative_base)
      9 -> process_move_relative_base_instruction(instruction, program, input, pointer, relative_base)
      99 -> process_halt_instruction(instruction, program, input, pointer, relative_base)
    end
  end

  def process_sum_instruction(instruction, program, input, pointer, relative_base) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program, relative_base)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program, relative_base)
    target = get_address(instruction.third_mode, Enum.at(program, pointer + 3), relative_base)
    {List.replace_at(program, target, a + b), input, pointer + 4, relative_base, nil, :go}
  end

  def process_mul_instruction(instruction, program, input, pointer, relative_base) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program, relative_base)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program, relative_base)
    target = get_address(instruction.third_mode, Enum.at(program, pointer + 3), relative_base)

    {List.replace_at(program, target, a * b), input, pointer + 4, relative_base, nil, :go}
  end

  def process_input_instruction(instruction, program, input, pointer, relative_base) do
    {value, popped_input} = List.pop_at(input, 0)
    target = get_address(instruction.first_mode, Enum.at(program, pointer + 1), relative_base)
    {List.replace_at(program, target, value), popped_input, pointer + 2, relative_base, nil, :go}
  end

  def process_output_instruction(instruction, program, input, pointer, relative_base) do
    value = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program, relative_base)
    {program, input, pointer + 2, relative_base, value, :halt}
  end

  def process_jump_if_true_instruction(instruction, program, input, pointer, relative_base) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program, relative_base)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program, relative_base)

    next_pointer = if a != 0, do: b, else: pointer + 3
    {program, input, next_pointer, relative_base, nil, :go}
  end

  def process_jump_if_false_instruction(instruction, program, input, pointer, relative_base) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program, relative_base)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program, relative_base)

    next_pointer = if a == 0, do: b, else: pointer + 3
    {program, input, next_pointer, relative_base, nil, :go}
  end

  def process_less_than_instruction(instruction, program, input, pointer, relative_base) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program, relative_base)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program, relative_base)
    target = get_address(instruction.third_mode, Enum.at(program, pointer + 3), relative_base)

    value = if a < b, do: 1, else: 0
    {List.replace_at(program, target, value), input, pointer + 4, relative_base, nil, :go}
  end

  def process_equals_instruction(instruction, program, input, pointer, relative_base) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program, relative_base)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program, relative_base)
    target = get_address(instruction.third_mode, Enum.at(program, pointer + 3), relative_base)

    value = if a == b, do: 1, else: 0
    {List.replace_at(program, target, value), input, pointer + 4, relative_base, nil, :go}
  end

  def process_move_relative_base_instruction(instruction, program, input, pointer, relative_base) do
    value = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program, relative_base)
    {program, input, pointer + 2, relative_base + value, nil, :go}
  end

  def process_halt_instruction(_, program, input, _pointer, _relative_base) do
    {program, input, -1, -1, nil, :halt}
  end

  @spec get_value(0 | 1 | 2, integer, [integer], integer) :: integer
  def get_value(0, position, program, _relative_base), do: Enum.at(program, position)
  def get_value(1, value, _program, _relative_base),  do: value
  def get_value(2, value, program, relative_base) do
    Enum.at(program, relative_base + value)
  end

  @spec get_address(0 | 2, integer, integer) :: any
  def get_address(0, value, _relative_base), do: value
  def get_address(2, value, relative_base), do: relative_base + value

  @spec parse_instruction(integer) :: Day9.Intcode.t()
  def parse_instruction(instruction) do
    [_, a, b, c | de] = Integer.digits(instruction + 100_000)
    %Intcode{
      opcode: Integer.undigits(de),
      first_mode: c,
      second_mode: b,
      third_mode: a
    }
  end
end
