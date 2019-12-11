defmodule Day6 do
  @type orbit :: [String.t()]
  @type orbit_map :: Map.t([String.t()])

  @spec input_to_orbits :: [orbit]
  defp input_to_orbits do
    File.read!("input.txt")
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ")"))
  end

  def part1 do
    input_to_orbits()
    |> build_orbit_acg
    |> count_orbits("COM")
  end

  def part2 do
    input_to_orbits()
    |> build_orbit_graph
    |> find_transfers("YOU")
  end

  @spec build_orbit_acg(any) :: any
  def build_orbit_acg(orbits) do
    orbits |> Enum.reduce(Map.new(), &add_orbiter/2)
  end

  def build_orbit_graph(orbits) do
    orbits |> Enum.reduce(Map.new(), &add_bidirectional_orbiter/2)
  end

  @spec add_orbiter([String.t()], map) :: map
  def add_orbiter([orbitee, orbiter | _], map) do
    Map.put(map, orbitee, [orbiter | Map.get(map, orbitee, [])])
  end

  def add_bidirectional_orbiter([orbitee, orbiter | _], map) do
    directional = add_orbiter([orbitee, orbiter], map)
    Map.put(directional, orbiter, [orbitee | Map.get(map, orbiter, [])])
  end

  @spec count_orbits(map, String.t(), number) :: number
  def count_orbits(orbit_map, from, acc \\ 0) do
    Map.get(orbit_map, from, [])
    |> Enum.map(&count_orbits(orbit_map, &1, acc + 1))
    |> Enum.sum()
    |> Kernel.+(acc)
  end

  def find_transfers(orbit_graph, current, visited \\ MapSet.new(), count \\ 0)
  def find_transfers(_, "SAN", _, count), do: count - 2

  def find_transfers(orbit_graph, current, visited, count) do
    visited = MapSet.put(visited, current)
    neighbors = Map.get(orbit_graph, current, []) |> Enum.reject(&MapSet.member?(visited, &1))

    IO.inspect(current)

    neighbors
    |> Enum.map(&find_transfers(orbit_graph, &1, visited, count + 1))
    |> Enum.find(&(!is_nil(&1)))
  end
end
