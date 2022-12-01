defmodule Day14 do

  @trillion 1_000_000_000_000
  def input_to_reaction(filename \\ "input.txt") do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.map(&line_to_reaction/1)
  end

   @doc """
    iex> Day14.line_to_reaction("1 SFJFX, 3 MXNK => 4 NLSBZ")
    %{input: [%{amount: 1, element: "SFJFX"}, %{amount: 3, element: "MXNK"}], output: %{amount: 4, element: "NLSBZ"}}
  """
  def line_to_reaction(line) do
    [left, right] = String.split(line, " => ")

    input = Enum.map(String.split(left, ", "), &str_to_component/1)
    %{:input => input, output: str_to_component(right)}
  end

  @doc """
    iex> Day14.str_to_component("6 WBVJ")
    %{element: "WBVJ", amount: 6}
  """
  def str_to_component(component_str) do
    [left, right] = String.split(component_str, " ")
    %{:element => right, :amount => String.to_integer(left)}
  end

  def part_1 do
    input_to_reaction()
    |> find_ore_amounts("FUEL", 1)
  end

  def part_2 do
    input_to_reaction()
    |> find_fuel_at_ores(@trillion)
  end

  def find_ore_amounts(_reactions, target_element, target_amount, inventory \\ Map.new())
  def find_ore_amounts(_reactions, "ORE", target_amount, inventory), do: {target_amount, inventory}
  def find_ore_amounts(_reactions, _target, 0, inventory), do: {0, inventory}
  def find_ore_amounts(reactions, target_element, target_amount, inventory) do
    my_reaction = Enum.find(reactions, fn x -> x.output.element == target_element end)
    {amount_from_inventory, inventory} = get_from_inventory(inventory, target_element, target_amount)
    needed_amount = target_amount - amount_from_inventory
    multiplier = ceil(needed_amount / my_reaction.output.amount)
    remainder = multiplier * my_reaction.output.amount - needed_amount
    inventory = Map.update(inventory, target_element, remainder, &(&1 + remainder))

    Enum.reduce(my_reaction.input, {0, inventory}, fn (x, {acc_amount, inventory}) ->
      needed_amount = x.amount * multiplier
      {amount, inventory} = find_ore_amounts(reactions, x.element, needed_amount, inventory)
      {amount + acc_amount, inventory}
    end)
  end


  def get_from_inventory(inventory, element, amount) do
    Map.get_and_update(inventory, element, fn inventory_amount ->
      if is_nil(inventory_amount) do
        {0, 0}
      else
        if inventory_amount > amount do
          {amount, inventory_amount - amount}
        else
          {inventory_amount, 0}
        end
      end
    end)
  end

  def find_fuel_at_ores(reactions, max) do
    {ore_per_one_fuel, _} = find_ore_amounts(reactions, "FUEL", 1)
    binary_search(1, ore_per_one_fuel * max, reactions)
  end

  def binary_search(min, max, _reactions) when min > max, do: max
  def binary_search(min, max, reactions) do
    fuel = div(min + max, 2)
    {ores_at_fuel, _} = find_ore_amounts(reactions, "FUEL", fuel)
    case ores_at_fuel <= @trillion do
      true -> binary_search(fuel + 1, max, reactions)
      false -> binary_search(min, fuel - 1, reactions)
    end
  end

end
