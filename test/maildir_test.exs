defmodule MaildirTest do
  use ExUnit.Case
  doctest Maildir

  test "it should be possible to create a maildir" do
    # Get a temporary folder
    maildir = HelperTest.mktemp_d()

    # Create the maildir
    maildir = Maildir.create(maildir)

    assert File.dir?(maildir)
    assert File.dir?(maildir <> "/new")
    assert File.dir?(maildir <> "/tmp")
    assert File.dir?(maildir <> "/cur")
  end
end
