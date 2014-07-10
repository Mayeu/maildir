defmodule Maildir.FilenameTest do
  use ExUnit.Case
  doctest Maildir.Filename

  test "generated name should be valid" do
    name = Maildir.Filename.gen()

    assert String.match?(name, ~r/\A[0-9]+\.[0-9a-f]+\.\w+:2,\z/)
  end

  test "parsing a name should return the good uniq and info part" do
    filename = "1204640692.77732e38c8d0e510cbaa8692d56729032c44fb3c785f18fa81750320955.azathoth:2,"
    {uniq, info} = Maildir.Filename.parse(filename)

    assert uniq == "1204640692.77732e38c8d0e510cbaa8692d56729032c44fb3c785f18fa81750320955.azathoth"
    assert info == "2,"
  end

  test "update the flags" do
    info = "2,"

    assert Maildir.Filename.update_flags(info, :passed, :add) == "2,P"
    assert Maildir.Filename.update_flags(info, :replied, :add) == "2,R"
    assert Maildir.Filename.update_flags(info, :seen, :add) == "2,S"
    assert Maildir.Filename.update_flags(info, :trashed, :add) == "2,T"
    assert Maildir.Filename.update_flags(info, :draft, :add) == "2,D"
    assert Maildir.Filename.update_flags(info, :flagged, :add) == "2,F"

    info = Maildir.Filename.update_flags(info, :passed, :add)
    assert info == "2,P"

    info = Maildir.Filename.update_flags(info, :passed, :remove)
    assert info == "2,"

    info = Maildir.Filename.update_flags(info, :replied, :add)
    assert info == "2,R"

    info = Maildir.Filename.update_flags(info, :draft, :add)
    assert info == "2,DR"

    info = Maildir.Filename.update_flags(info, :trashed, :add)
    assert info == "2,DRT"

    info = Maildir.Filename.update_flags(info, :passed, :add)
    assert info == "2,DPRT"

    info = Maildir.Filename.update_flags(info, :replied, :remove)
    assert info == "2,DPT"

    info = Maildir.Filename.update_flags(info, :draft, :remove)
    assert info == "2,PT"

    info = Maildir.Filename.update_flags(info, :trashed, :remove)
    assert info == "2,P"
  end
end
