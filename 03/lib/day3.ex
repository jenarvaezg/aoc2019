defmodule Day3 do
  @moduledoc """
  Implementation for advent of code for Day3.
  """

  @type coordinate :: %{required(:x) => integer, required(:y) => integer}
  @type path :: [coordinate]

  @deltas %{
    "R" => %{:x => 1, :y => 0},
    "L" => %{:x => -1, :y => 0},
    "U" => %{:x => 0, :y => 1},
    "D" => %{:x => 0, :y => -1}
  }

  @spec input_to_charlists :: [[charlist]]
  def input_to_charlists do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
  end

  @spec part1 :: integer
  def part1 do
    input_to_charlists()
    |> part1
  end

  @doc """
    Implementation of part 1

    Examples:
    iex> Day3.part1([["R75","D30","R83","U83","L12","D49","R71","U7","L72"], ["U62","R66","U55","R34","D71","R55","D58","R83"]])
    159

    iex> Day3.part1([["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"], ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"]])
    135
  """
  @spec part1([[charlist]]) :: integer
  def part1(charlists) do
    charlists
    |> Enum.map(fn wire ->
      wire
      |> Enum.map(&instruction_to_coordinate/1)
      |> calculate_full_paths
    end)
    |> get_intersections
    |> find_nearest_point
    |> manhattan_distance
  end

  def part2 do
    input_to_charlists()
    |> part2
  end

  @doc """
    Implementation for part 2

    Examples:
    iex> Day3.part2([["R75","D30","R83","U83","L12","D49","R71","U7","L72"], ["U62","R66","U55","R34","D71","R55","D58","R83"]])
    610

    iex> Day3.part2([["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"], ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"]])
    410
  """
  @spec part2([[charlist]]) :: integer
  def part2(charlists) do
    wires_paths =
      charlists
      |> Enum.map(fn wire ->
        wire
        |> Enum.map(&instruction_to_coordinate/1)
        |> calculate_full_paths
      end)

    get_intersections(wires_paths)
    |> find_shortest_path(wires_paths)
  end

  @doc """
    Calculates the full path a wire makes, give a list of coordinates, which are vectors where
    the wire turns

    Examples:
    iex> Day3.calculate_full_paths([%{x: -2, y: 0}, %{x: 0, y: -2}, %{x: 3, y: 0}])
    [
      %{x: -1, y: 0},
      %{x: -2, y: 0},
      %{x: -2, y: -1},
      %{x: -2, y: -2},
      %{x: -1, y: -2},
      %{x: 0, y: -2},
      %{x: 1, y: -2}
    ]
  """
  @spec calculate_full_paths([coordinate]) :: path
  def calculate_full_paths(coordinates) do
    coordinates
    |> Enum.reduce([], fn vector, acc ->
      cond do
        Enum.count(acc) == 0 -> build_path(%{:x => 0, :y => 0}, vector)
        true -> acc ++ build_path(List.last(acc), vector)
      end
    end)
  end

  @doc """
    Given a instruction, returns a coordinate

    Examples:
    iex> Day3.instruction_to_coordinate("R997")
    %{:x => 997, :y => 0}
  """
  @spec instruction_to_coordinate(String.t()) :: coordinate
  def instruction_to_coordinate(instruction) do
    [direction | count] = String.graphemes(instruction)
    count_int = Enum.join(count) |> String.to_integer()

    @deltas[direction]
    |> (fn delta -> %{:x => delta.x * count_int, :y => delta.y * count_int} end).()
  end

  @doc """
    Builds a path from an initial coordinate, following a straigth vector,
    without the initial point

    Examples:
    iex> Day3.build_path(%{:x => 0, :y => 0}, %{:x => 2, :y => 0})
    [%{:x => 1, :y => 0}, %{:x => 2, :y => 0}]

    iex> Day3.build_path(%{:x => 1, :y => 0}, %{:x => 0, :y => 2})
    [ %{:x => 1, :y => 1}, %{:x => 1, :y => 2}]
  """
  @spec build_path(coordinate, coordinate) :: path
  def build_path(initial_coordinate, vector) do
    for(x <- 0..vector.x, y <- 0..vector.y, do: {x, y})
    |> Enum.map(fn {x, y} ->
      %{:x => initial_coordinate.x + x, :y => initial_coordinate.y + y}
    end)
    |> Enum.filter(fn coord -> coord != initial_coordinate end)
  end

  @doc """
    Returns a mapset with intersections given a list of paths

    Examples:
    iex> Day3.get_intersections([[%{:x => 1, :y => 0}, %{:x => 2, :y => 0}, %{:x => 2, :y => 1}], [%{:x => 0, :y => 1}, %{:x => 1, :y => 1}, %{:x => 2, :y => 1}]])
    #MapSet<[%{x: 2, y: 1}]>
  """
  @spec get_intersections([path]) :: MapSet.t(coordinate)
  def get_intersections(paths) do
    paths
    |> Enum.reduce(nil, fn x, acc ->
      cond do
        acc == nil ->
          MapSet.new(x)

        true ->
          MapSet.new(x)
          |> MapSet.intersection(acc)
      end
    end)
  end

  @doc """
    Finds the nearest point to origin (0, 0), via Manhattan distance

    Examples:
    iex> Day3.find_nearest_point(MapSet.new([%{:x => 1, :y => 0}, %{:x => 1, :y => 1}]))
    %{:x => 1, :y => 0}
  """
  @spec find_nearest_point(MapSet.t(coordinate)) :: coordinate
  def find_nearest_point(points) do
    points
    |> Enum.min_by(&manhattan_distance/1)
  end

  @doc """
    Returns the manhattan distance from a coordinate to origin (0, 0)
    Examples:
    iex> Day3.manhattan_distance(%{:x => 1, :y => 0})
    1

    iex> Day3.manhattan_distance(%{:x => 10, :y => 5})
    15
  """
  @spec manhattan_distance(coordinate) :: number
  def manhattan_distance(coordinate) do
    abs(coordinate.x) + abs(coordinate.y)
  end

  def find_shortest_path(intersections, paths) do
    shortest_intersection =
      intersections
      |> Enum.min_by(&calculate_path_steps(&1, paths))

    calculate_path_steps(shortest_intersection, paths)
  end

  @doc """
    Given a point and a list of paths, calculate the sum of steps per path until the given point

    Examples:
    iex> Day3.calculate_path_steps(%{:x => 2, :y => 0}, [[%{:x => 1, :y => 0}, %{:x => 2, :y => 0}, %{:x => 2, :y => 1}], [%{:x => 1, :y => 0}, %{:x => 1, :y => 1}, %{:x => 2, :y => 1}, %{:x => 2, :y => 0}]])
    6

    iex> Day3.calculate_path_steps(%{:x => 2, :y => 0}, [[%{:x => 1, :y => 0}, %{:x => 2, :y => 0}, %{:x => 2, :y => 1}, %{:x => 2, :y => 0}], [%{:x => 1, :y => 0}, %{:x => 1, :y => 1}, %{:x => 2, :y => 1}, %{:x => 2, :y => 0}]])
    6

  """
  def calculate_path_steps(point, paths) do
    paths
    |> Enum.map(fn path ->
      path
      |> Enum.find_index(fn x -> x == point end)
      |> Kernel.+(1)
    end)
    |> Enum.sum()
  end
end
