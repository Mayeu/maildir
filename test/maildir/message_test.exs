defmodule Maildir.MessageTest do
  use ExUnit.Case
  doctest Maildir.Message

  test "creating a message should work with the default value" do
    maildir = "/tmp/maildir"
    message = Maildir.Message.create(maildir)

    assert message.maildir == maildir
    assert message.folder == :tmp
    assert String.match?(message.uniq, ~r/\A[0-9]+\.[0-9a-f]+\.\w+\z/)
    assert message.info == :nil

    # Given something else than a String should not work
    assert_raise FunctionClauseError, fn ->
      Maildir.Message.create([])
    end
    assert_raise FunctionClauseError, fn ->
      Maildir.Message.create(%{})
    end
  end

  test "returning the filename should works" do
    message_path = "/path/cur/1204680122.27c448163e3a5979a5b18219552.azathoth:2,"
    filename = "1204680122.27c448163e3a5979a5b18219552.azathoth:2,"

    assert Maildir.Message.filename(message_path) == filename

    message = %Maildir.Message{
      maildir: "/path",
      folder: :cur,
      uniq: "1204680122.27c448163e3a5979a5b18219552.azathoth",
      info: "2,"}

    assert Maildir.Message.filename(message) == filename
  end

  test "returning full path to a message should works" do
    message_path = "/path/cur/1204680122.27c448163e3a5979a5b18219552.azathoth:2,"

    message = %Maildir.Message{
      maildir: "/path",
      folder: :cur,
      uniq: "1204680122.27c448163e3a5979a5b18219552.azathoth",
      info: "2,"}

    assert Maildir.Message.path(message) == message_path

    message_path = "/path/new/1204680122.27c448163e3a5979a5b18219552.azathoth:2,"

    message = %Maildir.Message{
      maildir: "/path",
      folder: :new,
      uniq: "1204680122.27c448163e3a5979a5b18219552.azathoth",
      info: "2,"}

    assert Maildir.Message.path(message) == message_path
  end

  test "update the flags" do
    info = "2,"

    assert Maildir.Message.update_flags(info, :passed, :add) == "2,P"
    assert Maildir.Message.update_flags(info, :replied, :add) == "2,R"
    assert Maildir.Message.update_flags(info, :seen, :add) == "2,S"
    assert Maildir.Message.update_flags(info, :trashed, :add) == "2,T"
    assert Maildir.Message.update_flags(info, :draft, :add) == "2,D"
    assert Maildir.Message.update_flags(info, :flagged, :add) == "2,F"

    info = Maildir.Message.update_flags(info, :passed, :add)
    assert info == "2,P"

    info = Maildir.Message.update_flags(info, :passed, :remove)
    assert info == "2,"

    info = Maildir.Message.update_flags(info, :replied, :add)
    assert info == "2,R"

    info = Maildir.Message.update_flags(info, :draft, :add)
    assert info == "2,DR"

    info = Maildir.Message.update_flags(info, :trashed, :add)
    assert info == "2,DRT"

    info = Maildir.Message.update_flags(info, :passed, :add)
    assert info == "2,DPRT"

    info = Maildir.Message.update_flags(info, :replied, :remove)
    assert info == "2,DPT"

    info = Maildir.Message.update_flags(info, :draft, :remove)
    assert info == "2,PT"

    info = Maildir.Message.update_flags(info, :trashed, :remove)
    assert info == "2,P"
  end

  test "joining filename should work with or without info" do
    m = %Maildir.Message{
      maildir: "/tmp/maildir",
      folder: :tmp,
      uniq: "1204680122.27c448163e3a5979a5b18219552.azathoth",
      info: "2,"}

    assert Maildir.Message.join(m.uniq, m.info) == "1204680122.27c448163e3a5979a5b18219552.azathoth:2,"

    m = %Maildir.Message{
      maildir: "/tmp/maildir",
      folder: :tmp,
      uniq: "1204680122.27c448163e3a5979a5b18219552.azathoth",
      info: nil}

    assert Maildir.Message.join(m.uniq, m.info) == "1204680122.27c448163e3a5979a5b18219552.azathoth"
  end

  test "rename should actually moved file around" do
    # Get a tmp file
    {tmp, _} = System.cmd("mktemp", [])
    tmp = String.rstrip(tmp)

    new = tmp <> "-renamed"

    # Rename it
    assert new == Maildir.Message.rename(tmp, new)
    # Assert it exist
    assert File.exists?(new)
  end

  test "a message in new should be processed to cur" do
    # Get a fake maildir
    maildir = :os.cmd('mktemp -d')
    |> :erlang.iolist_to_binary
    |> String.rstrip

    # Create folders in it
    File.mkdir!(maildir <> "/tmp")
    File.mkdir!(maildir <> "/new")
    File.mkdir!(maildir <> "/cur")

    # Create a message
    m = Maildir.Message.create(maildir)

    # Artificialy move it to new, and touch it to existance
    m = %{m | folder: :new}
    File.touch!(Maildir.Message.path(m))

    # The processed message should look like this
    processed = %{m | folder: :cur, info: "2,"}

    # Now process it
    assert Maildir.Message.path(processed) == Maildir.Message.process(m)

    # Assert it exist
    assert File.exists?(Maildir.Message.path(processed))

  end

end
