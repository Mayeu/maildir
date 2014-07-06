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

  test "adding a flags should only change the info part" do
    filename = "1204640692.77732e38c8d0e510cbaa8692d56729032c44fb3c785f18fa81750320955.azathoth:2,"
    {orig_uniq, orig_info} = Maildir.Filename.parse(filename)

    # P, R, S, T, D, F
    filename = Maildir.Filename.add_flag(filename, :replied)
    {uniq, info} = Maildir.Filename.parse(filename)
    assert info != orig_info
    assert info == "2,R"
    assert uniq == orig_uniq

    filename = Maildir.Filename.add_flag(filename, :passed)
    {uniq, info} = Maildir.Filename.parse(filename)
    assert info != orig_info
    assert info == "2,PR"
    assert uniq == orig_uniq

    filename = Maildir.Filename.add_flag(filename, :draft)
    {uniq, info} = Maildir.Filename.parse(filename)
    assert info != orig_info
    assert info == "2,DPR"
    assert uniq == orig_uniq
  end
end
