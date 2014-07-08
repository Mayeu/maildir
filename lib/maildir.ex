defmodule Maildir do
  @doc """
  Mark an e-mail identified by its path, as replied

  Return its new path.

      iex> Maildir.reply("/path/1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth:2,")
      "/path/1204680122.27c448351529ae6fd8673e346ba5979a5b10a0f2427ff89716782219552.azathoth:2,R"
  """
  def reply(p) do
    path = Path.split(p)
    {uniq, info} = List.last(path) |> Maildir.Filename.parse
    info = Maildir.Filename.update_flags(info, :replied, :add)
    filename = uniq <> ":" <> info
    List.replace_at(path, -1, filename)
    |> Path.join
  end
end
