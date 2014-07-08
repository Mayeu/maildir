defmodule Maildir.Filename do
  @moduledoc """
  Handle all the filename need for maildir.
  """

  # Public API

  @doc """
  Generate an unique name for the e-mail.

  A unique name is composed of 2 parts separated by a colon:

   1. the *uniq* part. That should be unique
   2. the *info* part, containing information about the state of the e-mail

  The *uniq* is composed of 3 parts separated by dots:

    1. The result of the unix function time()
    2. A random part (see specs for the possible rules)
    3. The name of the computer delivering the e-mail
  """
  def gen do
    gen_uniq_part
    |> add_info_part
  end

  @doc """
  Parse the filename and return the *uniq* and *info* part.

      iex> Maildir.Filename.parse("1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth:2,")
      {"1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth", "2,"}
  """
  def parse(name) when is_binary(name) do
    [uniq, info] = String.split(name, ":")
    {uniq, info}
  end

  @doc """
  Update the flags from the info part.

  The only valid flags are:
    * P: `:passed`
    * R: `:replied`
    * S: `:seen`
    * T: `:trashed`
    * D: `:draft`
    * F: `:flagged`
  """
  def update_flags(info, flag, action)

  def update_flags(info, flag, :add) do
    case flag do
      :passed  -> add_flag(info, "P")
      :replied -> add_flag(info, "R")
      :seen    -> add_flag(info, "S")
      :trashed -> add_flag(info, "T")
      :draft   -> add_flag(info, "D")
      :flagged -> add_flag(info, "F")
      _        -> :error
    end
  end

  def update_flags(info, flag, :remove) do
    case flag do
      :passed  -> remove_flag(info, "P")
      :replied -> remove_flag(info, "R")
      :seen    -> remove_flag(info, "S")
      :trashed -> remove_flag(info, "T")
      :draft   -> remove_flag(info, "D")
      :flagged -> remove_flag(info, "F")
      _        -> :error
    end
  end

  def update_flags(_, _, _) do
    :error
  end

  # Private API

  # Generate the "uniq" part of the filename.
  defp gen_uniq_part do
    get_time()
    |> add_random_part
    |> add_computer_name
  end

  # Concat the basic empty "info" part to a "uniq" part
  defp add_info_part(uniq_part) do
    uniq_part <> ":2,"
  end

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

  # Add a flag in the info part
  defp add_flag(info, flag) do
    # Separate the flag part
    [version, flags] = String.split(info, ",")
    # Add and reorder the flag
    version <> "," <> order_flags(flags <> flag)
  end

  # Remove a flag from the info part
  defp remove_flag(info, flag) do
    String.split(info, ~r{})
    |> List.delete(flag)
    |> Enum.join
  end

  # Order flags of the info part
  defp order_flags(flags) do
    String.split(flags, ~r{})
    |> Enum.sort
    |> Enum.join
  end
end
