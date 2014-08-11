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

  test "open should detect if a folder is not a maildir" do
    # This path does not exist
    not_maildir = "/this/path/does/not/exist/unless/your/system/is/really/weird"
    assert {:error, _} = Maildir.open(not_maildir)

    # Test an empty temporary folder
    not_maildir = HelperTest.mktemp_d()
    assert {:error, _} = Maildir.open(not_maildir)

    # A folder with a random folder inside
    not_maildir = HelperTest.mktemp_d()
    File.mkdir!(not_maildir <> "/random_folder_name")
    assert {:error, _} = Maildir.open(not_maildir)

    # Now, a lot of test with various folder combination
    Enum.map(HelperTest.combos(["new", "tmp", "cur"]),
    fn (folders) ->
      # Get a tmp folder
      maildir = HelperTest.mktemp_d()
      # Create all the needed folder inside
      Enum.map(folders, fn (folder) -> File.mkdir!(maildir <> "/" <> folder) end)

      # If we are in the case of 3 folder, test that open work, otherwise,
      # test it does not
      case length(folders) do
        3 ->
          assert :ok = Maildir.open(maildir)
        _ ->
          assert {:error, _} = Maildir.open(maildir)
      end
    end)
  end
end
