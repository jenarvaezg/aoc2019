defmodule Day12 do

  def input_to_coordinates(file) do
    File.read!(file)
    |> String.split("\n")
    |> Enum.map(fn x ->
      [x, y, z] = Regex.scan(~r/(\-)?\d+/, x)
      |> Enum.map(&hd/1)
      |> Enum.map(&String.to_integer/1)
      %{:x => x, :y => y, :z => z}
    end)
  end

  def part_1(file \\ "input.txt", steps \\ 1000) do
    initial_coordinates = input_to_coordinates(file)
    initial_velocity = List.duplicate(%{:x => 0, :y => 0, :z => 0}, Enum.count(initial_coordinates))
    get_state_at(initial_coordinates, initial_velocity, steps)
    |> calculate_energy
  end

  def part_2(file \\ "input.txt") do
    initial_coordinates = input_to_coordinates(file)
    initial_velocity = List.duplicate(%{:x => 0, :y => 0, :z => 0}, Enum.count(initial_coordinates))
    find_loop_amount(initial_coordinates, initial_velocity)
  end

  def get_state_at(initial_coordinates, initial_velocities, n) do
    Enum.reduce(1..n, {initial_coordinates, initial_velocities}, fn (_, {coordinates, velocities}) ->
      process_step(coordinates, velocities)
    end)
  end

  def process_step(coordinates, velocities) do
    gravities = calculate_gravities(coordinates)
    new_velocities = Enum.zip(gravities, velocities) |> Enum.map(&sum_vectors/1)
    new_coordinates = Enum.zip(coordinates, new_velocities) |> Enum.map(&sum_vectors/1)
    {new_coordinates, new_velocities}
  end

  def find_loop_amount(initial_coordinates, initial_velocities) do
    axes = Enum.at(initial_coordinates, 0) |> Map.keys
    Enum.map(axes, fn axis ->
      initial_axes_values = get_axes(initial_coordinates, axis)
      Enum.reduce_while(1..1000000, {initial_coordinates, initial_velocities, 1}, fn (_, {coordinates, velocities, count}) ->
        {new_coordinates, new_velocities} = process_step(coordinates, velocities)
        axes_values = get_axes(new_coordinates, axis)
        if axes_values == initial_axes_values do
          {:halt, count + 1}
        else
          {:cont, {new_coordinates, new_velocities, count + 1}}
        end
      end)
    end)
    |> list_lcm

  end

  def calculate_gravities(planets_coordinates) do
    Enum.with_index(planets_coordinates)
    |> Enum.map(fn {planet, index} ->
      other_planets = List.delete_at(planets_coordinates, index)
      [x, y, z] = Enum.map(Map.keys(planet), fn axis ->
        Enum.reduce(other_planets, 0, fn (other_planet, count) ->
          count + gravity_between_planets(planet, other_planet, axis)
        end)
      end)
      %{:x => x, :y => y, :z => z}
    end)
  end

  @spec gravity_between_planets(map, map, atom) :: -1 | 0 | 1
  def gravity_between_planets(one, other, axis) do
    case Map.get(one, axis) - Map.get(other, axis) do
      diff when diff > 0 -> -1
      diff when diff < 0 -> 1
      _ -> 0
    end
  end

  def calculate_energy({positions, velocities}) do
    Enum.zip(positions, velocities)
    |> Enum.map(fn {position, velocity} ->
      potencial = Map.values(position) |> Enum.map(&Kernel.abs/1) |>  Enum.sum
      kinetic = Map.values(velocity) |> Enum.map(&Kernel.abs/1) |>  Enum.sum
      potencial * kinetic
      end)
    |> Enum.sum

  end

  def sum_vectors({one, other}) do
    %{
      :x => one.x + other.x,
      :y => one.y + other.y,
      :z => one.z + other.z
    }
  end

  def get_axes(coordinates, axis) do
    Enum.map(coordinates, &(Map.get(&1, axis)))
  end

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x,y))
  def list_lcm(values) do
    Enum.reduce(values, &(div(&1 * &2, gcd(&1, &2))))
  end
end
