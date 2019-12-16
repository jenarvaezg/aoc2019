defmodule Day16 do

  @base_pattern [0, 1, 0, -1]
  def input_to_int_list do
    File.read!("input.txt")
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
  end

  def part_1 do
    signal = input_to_int_list()
    Enum.reduce(1..100, signal, fn (x, signal) ->
      IO.inspect("#Round #{x}")
      fft(signal)
    end)
  end

  def part_2 do
    signal = input_to_int_list()
    |> get_signal_after_skip

    Enum.reduce(1..100, signal, fn (_, signal) ->
      Day16.fft_simple(signal)
    end)
    |> Enum.take(8)
    |> Enum.join
  end

  def get_signal_after_skip(initial_signal) do
    signal = List.duplicate(initial_signal, 10000) |> List.flatten
    skip_index = Enum.take(signal, 7) |> Enum.join |> String.to_integer
    Enum.drop(signal, skip_index)
  end

  def fft(signal) do
    signal_length = Enum.count(signal)
    signal_map = Enum.with_index(signal) |> Enum.map( fn {x, y} -> {y, x} end) |> Map.new
    Enum.map(1..signal_length, fn i ->
      pattern = pattern_at(i) |> Enum.take(signal_length) |> Enum.with_index |> Enum.map( fn {x, y} -> {y, x} end) |> Map.new
      values = for j <- i-1..signal_length - 1, Map.get(pattern, j) != 0, do: Map.get(pattern, j) * Map.get(signal_map, j)
      values
      |> Enum.sum
      |> Kernel.rem(10)
      |> Kernel.abs
    end)
  end

  def fft_simple(signal) do
    Enum.reverse(signal)
    |> Enum.scan(0, fn x, sum -> abs(sum + x) |> rem(10) end)
    |> Enum.reverse
  end

  def pattern_at(n) do
    {val, list} = Enum.map(@base_pattern, &(List.duplicate(&1, n)))
    |> List.flatten
    |> List.pop_at(0)

    Stream.cycle(list ++ [val])
  end

  # NO ES 24345612

end
