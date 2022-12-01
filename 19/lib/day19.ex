defmodule Day19 do


  def part_1 do
    Intcode.new_from_file("input.txt")
    |> generate_map(50)
    |> draw_map(50)
    |> Map.values
    |> Enum.count(&(&1 == 1))
  end

  def part_2 do
    map_size = 1100
    Intcode.new_from_file("input.txt")
    |> generate_map(map_size)
    # |> draw_map(map_size)
    |> get_box_fit(map_size, 100-1)
  end

  def generate_map(program, size) do

    Enum.reduce(0..size-1, Map.new(), fn (y, acc) ->
      IO.puts(y)
      previous_row = get_row(acc, y - 1)
      start_x = if previous_row == [] do
        0
      else
        {{first_x, _}, _} = sort_row(previous_row) |> hd
        max(first_x - 2, 0)
      end

      Map.merge(acc, Enum.reduce_while(start_x..size-1, Map.new(), fn (x, row_acc) ->
        {_program, output} = program |> Intcode.push_input(x) |> Intcode.push_input(y) |> Intcode.run_until_output
        if output == 1 do
          {:cont, Map.put(row_acc, {x, y}, output)}
        else
          if Enum.any?(row_acc, fn {_, val} -> val == 1 end) do
            {:halt, row_acc}
          else
            {:cont, row_acc}
          end
        end
      end))
    end)
  end

  def get_box_fit(map, map_size, box_size) do
    start_y = Enum.reduce_while(0..map_size-1, nil, fn (y, _acc) ->
      IO.puts(y)
      if count_rays_at_row(map, y) >= box_size do
        {:halt, y}
      else
        {:cont, nil}
      end
    end)

    Enum.reduce_while(start_y..map_size-1-box_size, nil, fn (y, _acc) ->
      IO.puts("AT ROW #{y}")
      row = get_row(map, y)
      box_bottom_row = get_row(map, y + box_size)
      {top_right_x, _} = Enum.max_by(row, fn {x, _y} -> x end)
      top_left = top_right_x - box_size
      IO.puts("TOP LEFT #{top_left} TOP RIGHT #{top_right_x} #{row |> Enum.count}")
      if {top_left, y + box_size} in box_bottom_row do
        coords = {top_left, y}
        {:halt, coords}
      else
        {:cont, nil}
      end
      # if Enum.count(row) > box_size do
      #   IO.puts("Maybe row #{y}?")
      #   vertical_count = Enum.count(row, fn {{x, y}, _val} -> count_rays_at_column_below_row(map, x, y) >= box_size end)
      #   |> IO.inspect

      #   if vertical_count >= box_size do
      #     {coords, _} = Enum.min_by(row, fn {{x, _y}, _val} -> x end)
      #     {:halt, coords}
      #   else
      #     {:cont, nil }
      #   end
      # else
      #   {:cont, nil}
      # end

    end)
  end

  def sort_row(row), do: Enum.sort(row, fn ({{x1, _}, _}, {{x2, _}, _}) -> x1 < x2 end) |> Enum.map(fn {coord, _val} -> coord end)

  def get_row(map, row_index), do: Enum.filter(map, fn {{_x, y}, _value} -> y == row_index end) |> Enum.map(fn {coord, _val} -> coord end)
  def get_column(map, column_index), do: Enum.filter(map, fn {{x, _y}, _value} -> x == column_index end) |> Enum.map(fn {coord, _val} -> coord end)


  def count_rays_at_row(map, row_index) do
    Enum.filter(map, fn {{_x, y}, _value} -> y == row_index end) |> Enum.count
  end

  def count_rays_at_column_below_row(map, column_index, row_index) do
    Enum.filter(map, fn {{x, _y}, _value} -> x == column_index end)
    |> Enum.filter(fn {{_x, y}, _value} -> y >= row_index end)
    |> Enum.count
  end

  def draw_map(map, size) do
    content = Enum.map(0..size-1, fn y ->
      row = Enum.map(0..size-1, fn x ->
        case  Map.get(map, {x, y}) do
          1 -> "#"
          0 -> "."
          nil -> " "
        end
      end)
      row ++ ["\n"]
    end)
    |> List.flatten
    |> Enum.join("")
    File.write!("ray1100.txt", content)
    map
  end
end


## 561 948
## 562 948
# no es 5610948, 625957 6250957
