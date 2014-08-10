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
end
