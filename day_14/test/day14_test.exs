defmodule Day14Test do
  use ExUnit.Case
  doctest Day14

  @trillion 1_000_000_000_000

  def test_file(x), do: "test/inputs/#{x}.txt"

  test "part 1 first example returns 31" do
    {31, _inventory} = test_file(1)
    |> Day14.input_to_reaction
    |> Day14.find_ore_amounts("FUEL", 1)
  end

  test "part 1 second example returns 165" do
    {165, _inventory} = test_file(2)
    |> Day14.input_to_reaction
    |> Day14.find_ore_amounts("FUEL", 1)
  end

  test "part 1 third example returns 13312" do
    {13312, _inventory} = test_file(3)
    |> Day14.input_to_reaction
    |> Day14.find_ore_amounts("FUEL", 1)

  end

  test "part 1 fourth example returns 180697" do
    {180697, _inventory} = test_file(4)
    |> Day14.input_to_reaction
    |> Day14.find_ore_amounts("FUEL", 1)
  end

  test "part 1 fifth example returns 165" do
    {2210736, _inventory} = test_file(5)
    |> Day14.input_to_reaction
    |> Day14.find_ore_amounts("FUEL", 1)
  end

  test "part 2 third example returns 82892753" do
    82892753 = test_file(3)
    |> Day14.input_to_reaction
    |> Day14.find_fuel_at_ores(@trillion)

  end

  test "part 2 fourth example returns 5586022" do
    5586022 = test_file(4)
    |> Day14.input_to_reaction
    |> Day14.find_fuel_at_ores(@trillion)
  end

  test "part 3 fifth example returns 460664" do
    460664 = test_file(5)
    |> Day14.input_to_reaction
    |> Day14.find_fuel_at_ores(@trillion)
  end

end

