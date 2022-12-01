defmodule Day8 do

  @spec input_to_pixels :: [integer]
  def input_to_pixels do
    File.read!("input.txt")
    |> String.trim()
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
  end


  def part_1 do
    input_to_pixels()
    |> build_layers({25, 6})
    |> Enum.map(fn layer ->
      zeros = Enum.count(layer, fn x -> x == 0 end)
      ones = Enum.count(layer, fn x -> x == 1 end)
      twos = Enum.count(layer, fn x -> x == 2 end)
      {zeros, ones, twos}
    end)
    |> Enum.min_by(fn {zeros, _, _} -> zeros end)
  end

  def part_2 do
    input_to_pixels()
    |> build_layers({25, 6})
    |> stack_layers
    |> image_to_printable_string
    |> IO.puts
  end

  @doc """
    iex> Day8.build_layers([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2], {3, 2})
    [[1, 2, 3, 4, 5, 6], [7, 8, 9, 0, 1, 2]]
  """
  def build_layers(pixels, {width, height}) do
    Enum.chunk_every(pixels, width * height)
  end

  @doc """
  """
  def stack_layers(layers) do
    num_pixels = Enum.count(Enum.at(layers, 0))
    for i <- 0..num_pixels-1, do: color_at(layers, i)
  end

  defp image_to_printable_string(image) do
    image
    |> Stream.map(&pixel_to_printable_char/1)
    |> Stream.chunk_every(25)
    |> Enum.intersperse(?\n)
  end

  defp pixel_to_printable_char(0), do: ?\s
  defp pixel_to_printable_char(1), do: ?*

  def color_at(layers, position, layer_pos \\ 0) do
    layer = Enum.at(layers, layer_pos)
    if layer == nil do
      2
    else
      color = Enum.at(layer, position)
      if color == 2 do
        color_at(layers, position, layer_pos + 1)
      else
        color
      end
    end
  end
end
