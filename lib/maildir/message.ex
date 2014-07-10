defmodule Maildir.Message do
  defstruct maildir: nil, folder: :tmp, uniq: nil, info: "2,"

  @doc """
  Process a message from `new` to `cur`
  """
  def process(path) when is_binary(path), do: :not_implemented
  def process(message) when is_map(message), do: :not_implemented
  def process(_), do: :error

  @doc """
  Return the full path of a message
  """
  def path(message) when is_map(message) do
    Path.join([message.maildir, Atom.to_string(message.folder), Maildir.Filename.join(message.uniq, message.info)])
  end

  # In case you give the path of the message
  def path(message) when is_binary(message) do
    {:error, "Expecting me to return you the path of the message given the path
    of the message does not make sense."}
  end

  @doc """
  Return the name of a message
  """
  def filename(message) when is_map(message) do
    Maildir.Filename.join(message.uniq, message.info)
  end

  def filename(path) when is_binary(path) do
    Path.basename(path)
  end

  @doc """
  Mark an e-mail identified by its path, as replied and return its new path.

      iex> Maildir.Message.reply("/path/1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth:2,")
      "/path/1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth:2,R"
  """
  def reply(p) do
    path = Path.split(p)
    {uniq, info} = List.last(path) |> Maildir.Filename.parse
    info = Maildir.Filename.update_flags(info, :replied, :add)
    filename = Maildir.Filename.join(uniq, info)
    List.replace_at(path, -1, filename)
    |> Path.join
  end

end
