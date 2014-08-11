ExUnit.start()

defmodule HelperTest do
  # Helper that return a temporary directory
  def mktemp_d do
    :os.cmd('mktemp -d')
    |> :erlang.iolist_to_binary
    |> String.rstrip
  end

  # Helper that return a temporary file
  def mktemp do
    :os.cmd('mktemp')
    |> :erlang.iolist_to_binary
    |> String.rstrip
  end

  # Combination for list, taken from: http://panduwana.wordpress.com/2010/04/21/combination-in-erlang/
  def combos(1, list) do
    for e <- list, do: [e]
  end
  def combos(k, list) when k == length(list), do: [list]
  def combos(k, [head | tail]) do
    (for sub <- combos(k-1, tail), do: [head|sub]) ++ combos(k, tail)
  end

  def combos(list) do
    List.foldl(:lists.seq(1,length(list)), [], fn (k, acc) -> acc ++ combos(k, list) end)
  end
end
