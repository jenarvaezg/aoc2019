defmodule Day7 do
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
    |> find_largest_output
  end

  def part2 do
    input_to_int_list()
    |> find_largest_output_with_feedback
  end

  @doc """
    Finds the setting that yields the best output

    Examples:
    iex> Day7.find_largest_output([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0])
    43210

    iex> Day7.find_largest_output([3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0])
    54321

    iex> Day7.find_largest_output([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33, 1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0])
    65210
  """
  def find_largest_output(program) do
    settings = [0, 1, 2, 3, 4]

    for a <- settings, b <- settings, c <- settings, d <- settings, e <- settings do
      if Enum.uniq([a, b, c, d, e]) |> length == 5 do
        compute_output(program, [a, b, c, d, e])
      end
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.max()
  end

  @doc """
    Computes output of chaining pogram inputs and outputs with a chain of inputs

    Examples:
    iex> Day7.compute_output([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], [4,3,2,1,0])
    43210

    iex> Day7.compute_output([3,23,3,24,1002,24,10,24,1002,23,-1,23, 101,5,23,23,1,24,23,23,4,23,99,0,0], [0,1,2,3,4])
    54321

    iex> Day7.compute_output([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33, 1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], [1,0,4,3,2])
    65210
  """
  def compute_output(program, settings) do
    Enum.reduce(settings, 0, fn x, acc ->
      {_, output, _} = process_program(program, [x, acc])
      output
    end)
  end

  @doc """
    iex> Day7.find_largest_output_with_feedback([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5])
    139629729

    iex> Day7.find_largest_output_with_feedback([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10])
    18216
  """
  def find_largest_output_with_feedback(program) do
    settings = [5, 6, 7, 8, 9]

    for a <- settings, b <- settings, c <- settings, d <- settings, e <- settings do
      if Enum.uniq([a, b, c, d, e]) |> length == 5 do
        programs = [program, program, program, program, program]
        compute_output_with_feedback(programs, [a, b, c, d, e])
      end
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.max()
  end

  @doc """
    iex> program = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
    iex> programs = [program, program, program, program, program]
    iex> Day7.compute_output_with_feedback(programs, [9,8,7,6,5])
    139629729

    iex> program = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]
    iex> programs = [program, program, program, program, program]
    iex> Day7.compute_output_with_feedback(programs, [9,7,8,5,6])
    18216
  """
  def compute_output_with_feedback(
        programs,
        settings,
        feedback \\ 0,
        iteration \\ 0,
        pointers \\ [0, 0, 0, 0, 0]
      ) do
    input_a = if iteration == 0, do: [Enum.at(settings, 0), feedback], else: [feedback]

    {program_a, output_a, pointer_a} =
      process_program(Enum.at(programs, 0), input_a, Enum.at(pointers, 0))

    input_b = if iteration == 0, do: [Enum.at(settings, 1), output_a], else: [output_a]

    {program_b, output_b, pointer_b} =
      process_program(Enum.at(programs, 1), input_b, Enum.at(pointers, 1))

    input_c = if iteration == 0, do: [Enum.at(settings, 2), output_b], else: [output_b]

    {program_c, output_c, pointer_c} =
      process_program(Enum.at(programs, 2), input_c, Enum.at(pointers, 2))

    input_d = if iteration == 0, do: [Enum.at(settings, 3), output_c], else: [output_c]

    {program_d, output_d, pointer_d} =
      process_program(Enum.at(programs, 3), input_d, Enum.at(pointers, 3))

    input_e = if iteration == 0, do: [Enum.at(settings, 4), output_d], else: [output_d]

    {program_e, output_e, pointer_e} =
      process_program(Enum.at(programs, 4), input_e, Enum.at(pointers, 4))

    case pointer_e do
      -1 ->
        feedback
      _ ->
        compute_output_with_feedback(
          [program_a, program_b, program_c, program_d, program_e],
          settings,
          output_e,
          iteration + 1,
          [pointer_a, pointer_b, pointer_c, pointer_d, pointer_e]
        )
    end
  end

  @doc """
    Processes a full program, instruction by instruction, returns the final program
    after processing all instructions
  """
  def process_program(program, input, pointer \\ 0) do
    instruction = parse_instruction(Enum.at(program, pointer))

    case process_instruction(instruction, program, input, pointer) do
      {program, _input, -1, output, :halt} ->
        {program, output, -1}

      {program, _input, next_pointer, output, :halt} ->
        {program, output, next_pointer}

      {program, input, next_pointer, nil, :go} ->
        process_program(program, input, next_pointer)
    end
  end

  def process_instruction(instruction, program, input, pointer) do
    case instruction.opcode do
      1 -> process_sum_instruction(instruction, program, input, pointer)
      2 -> process_mul_instruction(instruction, program, input, pointer)
      3 -> process_input_instruction(instruction, program, input, pointer)
      4 -> process_output_instruction(instruction, program, input, pointer)
      5 -> process_jump_if_true_instruction(instruction, program, input, pointer)
      6 -> process_jump_if_false_instruction(instruction, program, input, pointer)
      7 -> process_less_than_instruction(instruction, program, input, pointer)
      8 -> process_equals_instruction(instruction, program, input, pointer)
      99 -> process_halt_instruction(instruction, program, input, pointer)
    end
  end

  def process_sum_instruction(instruction, program, input, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)
    target = Enum.at(program, pointer + 3)
    {List.replace_at(program, target, a + b), input, pointer + 4, nil, :go}
  end

  def process_mul_instruction(instruction, program, input, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)
    target = Enum.at(program, pointer + 3)
    {List.replace_at(program, target, a * b), input, pointer + 4, nil, :go}
  end

  def process_input_instruction(_, program, input, pointer) do
    target = Enum.at(program, pointer + 1)
    {value, popped_input} = List.pop_at(input, 0)
    {List.replace_at(program, target, value), popped_input, pointer + 2, nil, :go}
  end

  def process_output_instruction(_, program, input, pointer) do
    target = Enum.at(program, pointer + 1)
    {program, input, pointer + 2, Enum.at(program, target), :halt}
  end

  def process_jump_if_true_instruction(instruction, program, input, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)

    next_pointer = if a != 0, do: b, else: pointer + 3
    {program, input, next_pointer, nil, :go}
  end

  def process_jump_if_false_instruction(instruction, program, input, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)

    next_pointer = if a == 0, do: b, else: pointer + 3
    {program, input, next_pointer, nil, :go}
  end

  def process_less_than_instruction(instruction, program, input, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)
    target = Enum.at(program, pointer + 3)

    value = if a < b, do: 1, else: 0
    {List.replace_at(program, target, value), input, pointer + 4, nil, :go}
  end

  def process_equals_instruction(instruction, program, input, pointer) do
    a = get_value(instruction.first_mode, Enum.at(program, pointer + 1), program)
    b = get_value(instruction.second_mode, Enum.at(program, pointer + 2), program)
    target = Enum.at(program, pointer + 3)

    value = if a == b, do: 1, else: 0
    {List.replace_at(program, target, value), input, pointer + 4, nil, :go}
  end

  def process_halt_instruction(_, program, input, _pointer) do
    {program, input, -1, nil, :halt}
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
