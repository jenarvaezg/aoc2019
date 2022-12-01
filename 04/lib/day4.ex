defmodule Day4 do

  @spec get_ranges :: {integer, integer}
  def get_ranges do
    [low, high | _ ] =File.read!("input.txt")
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    {low, high}
  end

  def part1 do
    get_ranges()
    |> part1
  end

  def part2 do
    get_ranges()
    |> part2
  end

  @spec part1({integer, integer}) :: any
  def part1({low, high}) do
    Enum.map(low..high, &is_valid_pincode/1)
    |> Enum.filter(fn x -> x end)
    |> Enum.count
  end

  @spec part2({integer, integer}) :: any
  def part2({low, high}) do
    Enum.map(low..high, &is_valid_pincode_no_big_group/1)
    |> Enum.filter(fn x -> x end)
    |> Enum.count
  end


  @doc """

    Examples:
    iex> Day4.is_valid_pincode(123456)
    false

    iex> Day4.is_valid_pincode(113456)
    true

    iex> Day4.is_valid_pincode(111111)
    true

    iex> Day4.is_valid_pincode(223450)
    false

    iex> Day4.is_valid_pincode(123789)
    false
  """
  @spec is_valid_pincode(integer) :: boolean
  def is_valid_pincode(pincode) do
    pincode
    |> Integer.to_string
    |> String.graphemes
    |> Enum.reduce(%{:consecutive => false, :increasing => true, :previous => ''}, fn (x, acc) ->
      consecutive = acc.consecutive or x == acc.previous
      increasing = acc.increasing and x >= acc.previous
      %{:consecutive => consecutive, :increasing => increasing, :previous => x}
    end)
    |> (fn result -> result.consecutive and result.increasing end).()

  end

  @doc """

    Examples:
    iex> Day4.is_valid_pincode_no_big_group(123456)
    false

    iex> Day4.is_valid_pincode_no_big_group(113456)
    true

    iex> Day4.is_valid_pincode_no_big_group(111111)
    false

    iex> Day4.is_valid_pincode_no_big_group(111122)
    true

    iex> Day4.is_valid_pincode_no_big_group(223450)
    false

    iex> Day4.is_valid_pincode_no_big_group(123789)
    false

    iex> Day4.is_valid_pincode_no_big_group(112222)
    true

    iex> Day4.is_valid_pincode_no_big_group(112233)
    true

    iex> Day4.is_valid_pincode_no_big_group(123444)
    false

    iex> Day4.is_valid_pincode_no_big_group(112333)
    true
  """
  @spec is_valid_pincode_no_big_group(integer) :: boolean
  def is_valid_pincode_no_big_group(pincode) do
    pincode
    |> Integer.to_string
    |> String.graphemes
    |> Enum.reduce(%{:consecutives => %{}, :increasing => true, :previous => ''}, fn (x, acc) ->
      now_consecutive = x == acc.previous
      increasing = acc.increasing and x >= acc.previous

      {_, consecutives} = Map.get_and_update(acc.consecutives,x, fn current ->
        current_as_int = if current == nil, do: 1, else: current
        case now_consecutive do
          true -> {current, current_as_int + 1}
          _ -> {current, current}
        end
      end)

      %{:consecutives => consecutives, :increasing => increasing, :previous => x}
    end)
    |> (fn result ->
      result.increasing and Map.values(result.consecutives) |> Enum.any?(fn x -> x == 2 end)
    end).()

  end
end
