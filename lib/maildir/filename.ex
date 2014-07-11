defmodule Maildir.Filename do
  @moduledoc """
  Handle the generation of unique name for the files, and parsing filename.
  """

  # Public API

  @doc """
  Generate an unique (*uniq*) name for the e-mail.

  The *uniq* is composed of 3 parts separated by dots:

    1. The result of the unix function time()
    2. A random part (see specs for the possible rules)
    3. The name of the computer delivering the e-mail
  """
  def gen do
    get_time
    |> add_random_part
    |> add_computer_name
  end

  @doc """
  Parse the filename and return a tuple containing *uniq* and either nil of the
  *info* part.

      iex> Maildir.Filename.parse("1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth:2,")
      {"1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth", "2,"}

      iex> Maildir.Filename.parse("1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth")
      {"1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth", nil}
  """
  def parse(name) when is_binary(name) do
    case String.contains?(name, ":") do
      true ->
        String.split(name, ":")
        |> List.to_tuple
      false ->
        {name, nil}
    end
  end

  # Private API

  # Get the time since epoch
  defp get_time do
    {mega_second, second, _} = :erlang.now()
    "#{mega_second}#{second}"
  end

  # Add the random part of the filename to the filename.
  #
  # This is a concatenation of Rn, Mn, Pn
  defp add_random_part(previous_part) do
    # Rn, a random part
    rn = get_random_hexa
    # Mn, the current microsecond
    {_, _, mn} = :erlang.now()
    # Pn, the process ID
    pn = System.get_pid

    previous_part <> "." <> rn <> Integer.to_string(mn) <> pn
  end

  # Add the name of the computer to the part
  defp add_computer_name(previous_part) do
    previous_part <> "." <> get_computer_name()
  end

  # Get the computer name and do some replacement to avoid weird char in the
  # name
  defp get_computer_name do
    System.cmd("hostname -s")
    |> String.replace("/", "\057")
    |> String.replace(":", "\072")
    |> String.rstrip
  end

  # Get 24 bytes of random data in hexadecimal
  defp get_random_hexa do
    :crypto.rand_bytes(24)
    |> Hexa.encode
  end
end
