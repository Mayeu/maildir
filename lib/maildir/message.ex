defmodule Maildir.Message do
  defstruct maildir: nil, folder: :tmp, uniq: nil, info: nil

  # The default empty info
  @info "2,"

  ##
  ## Public API

  @doc """
  Given a maildir path, return a message struct
  """
  def create(maildir) when is_binary(maildir) do
    %Maildir.Message{
      maildir: maildir,
      uniq: Maildir.Filename.gen()}
  end

  @doc """
  Process a message from `new` to `cur`
  """
  def process(path) when is_binary(path) do
    # TODO: check that the file exist
    process(to_message(path))
  end

  def process(m=%Maildir.Message{}), do: :not_implemented

  @doc """
  Return the full path of a message
  """
  def path(m=%Maildir.Message{}) do
    Path.join([m.maildir, Atom.to_string(m.folder), join(m.uniq, m.info)])
  end

  @doc """
  Return the name of a message
  """
  def filename(%Maildir.Message{uniq: uniq, info: info}) do
    join(uniq, info)
  end

  def filename(path) when is_binary(path) do
    Path.basename(path)
  end

  @doc """
  Given a uniq part and a info part, return the filename. An info part can be
  empty, so in this case it only returns the uniq part.
  """
  def join(uniq, nil) do
    uniq
  end

  def join(uniq, info) do
    uniq <> ":" <> info
  end

  @doc """
  Rename a message in the filesystem.

  Return the new path
  """
  def rename(src=%Maildir.Message{}, dest=%Maildir.Message{}) do
    rename(path(src), path(dest))
  end

  def rename(src=%Maildir.Message{}, dest) when is_binary(dest) do
    rename(path(src), dest)
  end

  def rename(src, dest=%Maildir.Message{}) when is_binary(src) do
    rename(src, path(dest))
  end

  def rename(src, dest) when is_binary(src) and is_binary(dest) do
    :not_implemented
  end

  @doc """
  Mark an e-mail identified by its path, as replied and return its new path.

      iex> Maildir.Message.reply("/path/1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth:2,")
      "/path/1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth:2,R"
  """
  # TODO: update this, it use some kind of old api
  def reply(p) do
    path = Path.split(p)
    {uniq, info} = List.last(path) |> Maildir.Filename.parse
    info = update_flags(info, :replied, :add)
    filename = join(uniq, info)
    List.replace_at(path, -1, filename)
    |> Path.join
  end

  # Private API

  # Transform a path to a message in a message struct
  defp to_message(path) do
    # Filename is the last element
    {filename, path} = pop(Path.split(path))

    # Now folder is the last element
    {folder, path} = pop(path)

    # Maildir is the joined path
    maildir = Path.join(path)

    # Uniq and info are extracted from the filename
    {uniq, info} = Maildir.Filename.parse(filename)

    # We can now build a message
    %Maildir.Message{
      maildir: maildir,
      folder: folder,
      uniq: uniq,
      info: info
    }
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

  ##
  ## Private api

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

  # Some kind of simple pop
  defp pop(list) do
    {List.last(list), List.delete_at(list, -1)}
  end
end
