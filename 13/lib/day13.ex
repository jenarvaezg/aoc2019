defmodule Day13 do
  @spec input_to_int_list :: [list(integer)]
  defp input_to_int_list do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part_1 do
    input_to_int_list()
    |> Intcode.new
    |> Intcode.run_until_halt
    |> Enum.chunk_every(3)
    |> build_board
    |> Enum.count(fn {_, v} -> v == 2 end)
  end

  def part_2(interactive \\ false) do
    input_to_int_list()
    |> (fn x -> List.replace_at(x, 0, 2) end).()
    |> Intcode.new
    |> play_game(interactive)
  end

  def build_board(values) do
    Enum.reduce(values, Map.new(), fn ([x, y, value], acc) ->
      Map.put(acc, {x, y}, value)
    end)
  end

  def play_game(%Intcode{} = program, interactive) do
    initial_state = %{
      :program => program,
      :score => 0,
      :board => Map.new(),
    }
    Enum.reduce_while(1..1000_000_000, initial_state, fn (_, acc) ->
      case get_next_message(acc.program) do
        {_program, [nil, nil, nil]} ->
          {:halt, acc.score}
        {program, message} ->
          new_state = update_state(program, acc, message)
          if interactive, do: display_game(new_state)
          {:cont, new_state}
      end
    end)
  end

  def get_next_message(program) do
    {program, output_1} = Intcode.run_until_output(program)
    {program, output_2} = Intcode.run_until_output(program)
    {program, output_3} = Intcode.run_until_output(program)
    {program, [output_1, output_2, output_3]}
  end

  def update_state(%Intcode{} = program, %{} = state, [-1, 0, score]) do
    %{
      state |
      :program => program,
      :score => score,
    }
  end

  def update_state(%Intcode{} = program, %{} = state, [x, y, 4]) do
    paddle = Enum.find(state.board, fn {_, val} -> val == 3 end)
    paddle_x = case paddle do
      nil -> 0
      {{paddle_x, _}, _} -> paddle_x
    end
    input = cond do
      paddle_x > x -> -1
      paddle_x < x -> 1
      true -> 0
    end
    %{
      state |
      :program => Intcode.push_input(program, input),
      :board => Map.put(state.board, {x, y}, 4),
    }
  end


  def update_state(%Intcode{} = program, %{} = state, [x, y, tile]) do
    %{
      state |
      :program => program,
      :board => Map.put(state.board, {x, y}, tile),
    }
  end
  def display_game(%{board: board, score: score}) do
    IO.write(IO.ANSI.clear())
    max_x = 41
    max_y = 24
    Enum.map(0..max_y, fn y ->
      row = Enum.map(0..max_x, fn x -> get_tile_display(Map.get(board, {x, y}, 0)) end)
      row ++ ["\n"]
    end)
    |> List.flatten
    |> Enum.join("")
    |> IO.puts
    IO.puts("Score: #{score}")

    if Enum.count(board) == (max_x + 1) * (max_y + 1), do: :timer.sleep(10)
  end

  def get_tile_display(0), do: " "
  def get_tile_display(1), do: "|"
  def get_tile_display(2), do: "#"
  def get_tile_display(3), do: "_"
  def get_tile_display(4), do: "O"
end
