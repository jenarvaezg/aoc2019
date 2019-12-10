defmodule Day10 do
  alias :math, as: Math

  def input_to_asteroid_map do
    File.read!("input.txt")
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end


  def part_1 do
    input_to_asteroid_map()
    |> get_asteroids
    |> compute_visibilities
    |> Enum.max_by(fn {count, _} -> count end)
  end

  def part_2 do
    asteroids = input_to_asteroid_map() |> get_asteroids
    {_, best_asteroid} = part_1()
    get_asteroid_destroyed_at(MapSet.delete(asteroids, best_asteroid), best_asteroid, 200)
  end

  @doc """
    iex> Day10.get_asteroids([[".","#","."], [".",".","."], ["#","#","#"]])
    #MapSet<[{1, 0}, {0, 2}, {1, 2}, {2, 2}]>
  """
  def get_asteroids(asteroid_map) do
    for(y <- 0..Enum.count(asteroid_map) - 1, x <- 0..Enum.count(Enum.at(asteroid_map, 0)) - 1, do: {x, y})
    |> Enum.reduce(MapSet.new(), fn ({x, y}, acc) ->
      case Enum.at(Enum.at(asteroid_map, y), x) do
        "#" -> MapSet.put(acc, %{:x => x, :y => y})
        "." -> acc
      end
    end)
  end

  def compute_visibilities(asteroids) do
    Enum.map(asteroids, fn asteroid ->
      count = Enum.map(MapSet.delete(asteroids, asteroid), &angle_between_asteroids(asteroid, &1))
      |> Enum.uniq
      |> Enum.count
      {count, asteroid}
    end)
  end

  def get_asteroid_destroyed_at(asteroids, from_asteroid, n) do
    Enum.reduce(asteroids, Map.new(),  fn (x, acc) ->
      angle = angle_between_asteroids(from_asteroid, x)
      distance = distance_between_asteroids(from_asteroid, x)
      asteroid_info = %{:asteroid => x, :angle => angle, :distance => distance}
      Map.update(acc, angle, [asteroid_info], &(&1 ++ [asteroid_info]))
    end)
    |> Map.values
    |> Enum.map(&sort_by_distance/1)
    |> Enum.sort(&sort_by_angle/2)
    |> Enum.map(fn x -> Enum.at(x, 0) end)
    |> Enum.at(n - 1)

  end

  def angle_between_asteroids(one, other) do
    radians = Math.atan2(other.y - one.y, other.x - one.x)
    degrees = radians * 180 / Math.pi() + 90
    if degrees < 0 do
      degrees + 360
    else
      degrees
    end
  end

  def distance_between_asteroids(one, other) do
    Math.sqrt(Math.pow(one.x - other.x, 2) + Math.pow(one.y - other.y, 2))
  end

  def sort_by_distance(asteroids_at_angle) do
    Enum.sort(asteroids_at_angle, &(&1.distance < &2.distance))
  end

  def sort_by_angle(first, second) do
    Enum.at(first, 0).angle < Enum.at(second, 0).angle
  end

end
