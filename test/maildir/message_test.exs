defmodule Maildir.MessageTest do
  use ExUnit.Case
  doctest Maildir.Message

  test "returning the filename should work" do
    message_path = "/path/cur/1204680122.27c448163e3a5979a5b18219552.azathoth:2,"
    filename = "1204680122.27c448163e3a5979a5b18219552.azathoth:2,"

    assert Maildir.Message.filename(message_path) == filename

    message = %Maildir.Message{
      maildir: "/path",
      folder: :cur,
      uniq: "1204680122.27c448163e3a5979a5b18219552.azathoth",
      info: "2,"}

    assert Maildir.Message.filename(message_path) == filename
  end
end
