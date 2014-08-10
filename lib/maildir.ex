defmodule Maildir do

  @doc """
  Simple function to ensure that a maildir exist and contains the three needed
  folder (`new`, `cur`, `tmp`)

  It is not needed to use it, since it just check that a maildir exist, nothing
  more.
  """
  def open(path) do
    :not_implemented
  end

  @doc """
  Create a maildir in the path given.

  Just create the 3 folders `cur`, `new`, `tmp` inside the given path passed as
  argument.
  """
  def create(path) do
    # Create the path if not existing
    File.mkdir_p! path

    # Create all the subfolders
    File.mkdir_p! path <> "/new"
    File.mkdir_p! path <> "/cur"
    File.mkdir_p! path <> "/tmp"

    path
  end

  @doc """
  Add a message in a maildir.

  Given a content and a maildir, this function add the message into the
  maildir.  It does not try to parse of validate the fact that the content is
  indeed an e-mail.
  """
  def add(maildir, message) do
    :not_implemented
  end

  @doc """
  List all the message in a folder. By returning a list of message.
  """
  def list(maildir, :new), do: :not_implemented
  def list(maildir, :cur), do: :not_implemented
  def list(_, _), do: :error
end
