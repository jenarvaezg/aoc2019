defmodule Day11 do
  @spec input_to_int_list :: [list(integer)]
  defp input_to_int_list do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part_1 do
    input_to_int_list()
    |> paint_ship
    |> Enum.count()
  end

  def part_2 do
    painting = Map.new() |> Map.put({0, 0}, 1)

    input_to_int_list()
    |> paint_ship(painting)
    |> painting_to_output
  end

  def paint_ship(
        program,
        painting \\ Map.new(),
        position \\ {0, 0},
        bearing \\ :up,
        pointer \\ 0,
        relative_base \\ -1
      ) do
    current_color = Map.get(painting, position, 0)

    {program, color_now, pointer, relative_base} =
      Intcode.process_program(program, [current_color], pointer, relative_base)

    case pointer do
      -1 ->
        painting

      _ ->
        {program, next_turn, pointer, relative_base} =
          Intcode.process_program(program, [], pointer, relative_base)

        painted_map = Map.put(painting, position, color_now)
        next_bearing = turn(bearing, next_turn)
        next_position = move(position, next_bearing)
        paint_ship(program, painted_map, next_position, next_bearing, pointer, relative_base)
    end
  end

  def painting_to_output(painting) do
    keys = Map.keys(painting)
    xs = Enum.map(keys, fn {x, _y} -> x end)
    ys = Enum.map(keys, fn {_x, y} -> y end)
    min_x = Enum.min(xs)
    min_y = Enum.min(ys)
    max_x = Enum.max(xs)
    max_y = Enum.max(ys)

    Enum.each(min_x..max_x, fn x ->
      Enum.each(min_y..max_y, fn y ->
        color = Map.get(painting, {x, y}, 0)

        case color do
          1 -> IO.write("#")
          _ -> IO.write(" ")
        end
      end)

      IO.puts("")
    end)
  end

  @spec turn(:down | :left | :right | :up, 0 | 1) :: :down | :left | :right | :up
  def turn(current_bearing, turn)
  def turn(:up, 0), do: :left
  def turn(:up, 1), do: :right
  def turn(:left, 0), do: :down
  def turn(:left, 1), do: :up
  def turn(:down, 0), do: :right
  def turn(:down, 1), do: :left
  def turn(:right, 0), do: :up
  def turn(:right, 1), do: :down

  def move(current_position, bearing)
  def move({x, y}, :up), do: {x, y + 1}
  def move({x, y}, :left), do: {x - 1, y}
  def move({x, y}, :down), do: {x, y - 1}
  def move({x, y}, :right), do: {x + 1, y}
end
