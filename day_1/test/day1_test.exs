defmodule Day1Test do
  use ExUnit.Case
  doctest Day1

  test "gets fuel by weight" do
    assert Day1.fuel_by_weight(12) == 2
    assert Day1.fuel_by_weight(14) == 2
    assert Day1.fuel_by_weight(1969) == 654
    assert Day1.fuel_by_weight(100756) == 33583
  end

  test "gets fuel recursively" do
    assert Day1.fuel_per_module_and_fuel(12) == 2
    assert Day1.fuel_per_module_and_fuel(1969) == 966
    assert Day1.fuel_per_module_and_fuel(100756) == 50346
  end
end
