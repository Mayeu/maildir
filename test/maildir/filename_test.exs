defmodule Maildir.FilenameTest do
  use ExUnit.Case
  doctest Maildir.Filename

  test "generated name should be valid" do
    name = Maildir.Filename.gen()

    assert String.match?(name, ~r/\A[0-9]+\.[0-9a-f]+\.\w+\z/)
  end

  test "parsing a name should return the good uniq and info part" do
    filename = "1204640692.77732e38c8d0e510cbaa8692d56729032c44fb3c785f18fa81750320955.azathoth:2,"
    {uniq, info} = Maildir.Filename.parse(filename)

    assert uniq == "1204640692.77732e38c8d0e510cbaa8692d56729032c44fb3c785f18fa81750320955.azathoth"
    assert info == "2,"

    filename = "1204640692.77732e38c8d0e510cbaa862d56729032c44b3c785f18fa8150320955.azathoth"
    {uniq, info} = Maildir.Filename.parse(filename)

    assert uniq == "1204640692.77732e38c8d0e510cbaa862d56729032c44b3c785f18fa8150320955.azathoth"
    assert info == nil
  end
end
