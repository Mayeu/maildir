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
  Add a flag to the info part.

  The only valid flags are:
    * P: `:passed`
    * R: `:replied`
    * S: `:seen`
    * T: `:trashed`
    * D: `:draft`
    * F: `:flagged`
  """
  def add_flag(f, :passed),  do: :not_implemented
  def add_flag(f, :replied), do: :not_implemented
  def add_flag(f, :seen),    do: :not_implemented
  def add_flag(f, :trashed), do: :not_implemented
  def add_flag(f, :draft),   do: :not_implemented
  def add_flag(f, :flagged), do: :not_implemented
  def add_flag(_, _),        do: :error

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

end
