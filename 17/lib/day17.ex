defmodule Day17 do

  def input_to_intlist do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part_1 do
    Intcode.new_from_file("input.txt")
    |> Intcode.run_until_halt
    |> parse_map
    |> find_intersections
    |> calculate_alignment_parameter
  end


  def part_2 do
    input_to_intlist()
    |> List.replace_at(0, 2)
    |> Intcode.new
    |> set_movement_routine
    |> define_movements
    |> set_video_feed(false)
    |> Intcode.run_until_halt
    |> Enum.take(-1)
  end

  def parse_map(map_int_list) do
    map_strings_list = map_int_list
    |> Enum.map(&(List.to_string([&1])))
    |> Enum.join
    |> String.trim_trailing
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> IO.inspect

    y_len = Enum.count(map_strings_list)
    x_len = Enum.count(Enum.at(map_strings_list, 0))
    Enum.at(map_strings_list, 0) |> Enum.at(0)
    for(y <- 0..y_len - 1, x <- 0..x_len - 1, do: {{x, y}, Enum.at(map_strings_list, y) |> Enum.at(x)})
    |> Map.new
  end

  def find_intersections(map) do
    Enum.filter(map, fn {coordinate, _} ->
      scaffold?(coordinate, map) and
      scaffold?(move(coordinate, :up), map) and
      scaffold?(move(coordinate, :down), map) and
      scaffold?(move(coordinate, :left), map) and
      scaffold?(move(coordinate, :right), map)
    end)
    |> Map.new
  end

  def calculate_alignment_parameter(map) do
    Map.keys(map)
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum
  end

  def set_movement_routine(program) do
    routine = "A,B,A,C,B,A,C,B,A,C\n" |> String.to_charlist
    Enum.reduce(routine, program, &(Intcode.push_input(&2, &1)))
  end

  def define_movements(program) do
    a = "L,6,L,4,R,12\n" |> String.to_charlist
    b = "L,6,R,12,R,12,L,8\n" |> String.to_charlist
    c = "L,6,L,10,L,10,L,6\n" |> String.to_charlist
    Enum.reduce(a ++ b ++ c, program, &(Intcode.push_input(&2, &1)))
  end

  def set_video_feed(program, feed) do
    value = (if feed, do: "y\n", else: "n\n") |> String.to_charlist |> IO.inspect
    Enum.reduce(value, program, &(Intcode.push_input(&2, &1)))
  end

  def scaffold?(coordinate, map), do: Map.get(map, coordinate) == "#"

  def move({x, y}, :up), do: {x, y - 1}
  def move({x, y}, :down), do: {x, y + 1}
  def move({x, y}, :left), do: {x - 1, y}
  def move({x, y}, :right), do: {x + 1, y}

  def coord_to_str({x, y}), do: "(#{x}, #{y})"

end
