defmodule Day15 do
  def part_1 do
    {_oxygen, map} =
      Intcode.new_from_file("input.txt")
      |> find_oxygen({0, 0}, init_map())

    draw_map(map)
  end

  def part_2 do
    map =
      Intcode.new_from_file("input.txt")
      |> explore_fully({0, 0}, init_map())

    draw_map(map)
  end

  def init_map do
    x_range = -19..21
    y_range = -21..19
    items = for x <- x_range, y <- y_range, do: {{x, y}, -1}
    Map.new(items)
  end

  def find_oxygen(program, current_position, map) do
    direction = get_viable_movement(current_position, map)
    future_position = move(current_position, direction)

    {program, output} =
      Intcode.push_input(program, direction)
      |> Intcode.run_until_output()

    map = Map.put(map, future_position, output)

    case output do
      # Wall, try same position different direction
      0 ->
        find_oxygen(program, current_position, map)

      # Movement ok!
      1 ->
        find_oxygen(program, future_position, map)

      # SUCCEESS
      2 ->
        IO.puts("FOUND AT #{coord_to_str(move(current_position, direction))}")
        {future_position, map}
    end
  end

  def explore_fully(program, current_position, map) do
    direction = get_viable_movement(current_position, map)
    future_position = move(current_position, direction)

    {program, output} =
      Intcode.push_input(program, direction)
      |> Intcode.run_until_output()

    map = Map.put(map, future_position, output)

    # If there is something yet to eexplore, keep going
    if Map.values(map) |> Enum.find(&(&1 == -1)) do
      case output do
        1 ->
          explore_fully(program, future_position, map)

        _ ->
          explore_fully(program, current_position, map)
      end
    else
      map
    end
  end

  def get_viable_movement(current_position, map) do
    # Prioritize unknown places
    direction =
      Enum.reduce_while(1..4 |> Enum.shuffle(), nil, fn x, _ ->
        test_position = move(current_position, x)

        if Map.get(map, test_position, -1) == -1 do
          {:halt, x}
        else
          {:cont, 0}
        end
      end)

    if direction == 0 do
      # Try to get a direction event if been there before
      direction =
        Enum.reduce_while(1..4 |> Enum.shuffle(), 0, fn x, _ ->
          test_position = move(current_position, x)
          IO.puts("#{coord_to_str(test_position)} #{Map.get(map, test_position, -1)}")
          if Map.get(map, test_position, -1) in [0, 2] do
            {:cont, 0}
          else
            {:halt, x}
          end
        end)
        IO.puts(coord_to_str(current_position))

      _ = 1 / direction
      direction
    else
      direction
    end
  end

  def move({x, y}, 1), do: {x, y - 1}
  def move({x, y}, 2), do: {x, y + 1}
  def move({x, y}, 3), do: {x + 1, y}
  def move({x, y}, 4), do: {x - 1, y}

  def coord_to_str({x, y}), do: "(#{x}, #{y})"

  def draw_map(map) do
    keys = Map.keys(map)
    xs = Enum.map(keys, fn {x, _y} -> x end)
    ys = Enum.map(keys, fn {_x, y} -> y end)
    min_x = Enum.min(xs)
    min_y = Enum.min(ys)
    max_x = Enum.max(xs)
    max_y = Enum.max(ys)

    IO.puts("DRAWING x: #{min_x}, #{max_x} y: #{min_y}, #{max_y}")

    Enum.each(min_y..max_y, fn y ->
      Enum.each(min_x..max_x, fn x ->
        tile = Map.get(map, {x, y}, -1)

        if x == 0 and y == 0 do
          IO.write("H")
        else
          case tile do
            2 -> IO.write(IO.ANSI.green() <> "X" <> IO.ANSI.reset())
            0 -> IO.write("#")
            -1 -> IO.write(".")
            _ -> IO.write(" ")
          end
        end
      end)

      IO.puts("")
    end)

    map
  end
end
