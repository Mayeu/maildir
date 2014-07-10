# Maildir

A maildir manipulation library for Elixir

## Warning

It is very much a work in progress. Things may breaks without any warning!
Everything details after this may not be implemente yet. I'll update this file
as the work progress.

## Usage

A maildir is simply a string representing a path to the maildir folder.

```elixir
iex> my_maildir = "/home/doctor/Maildir"
```

Still, there is an `Maildir.open` function defined to check that the path given
indeed contains the 3 folders `cur`, `new`, `tmp`. This function return the
path given if it is indeed a maildir, or :error otherwise.

```elixir
iex> my_maildir = Maildir.open("/home/doctor/Maildir")
"/home/doctor/Maildir"
iex> my_maildir = Maildir.open("/home/doctor/not_a_maildir")
:error
```

A `Message` is defined as follow:

```elixir
iex> defmodule Message do
...>   defstruct maildir: nil, folder: :tmp, uniq: nil, info: "2,"
...> end
```

The `maildir` field is effectively the path to the maildir, `folder` is one of
the `:cur`, `:new` or `:tmp` folder, `uniq` is the uniq part of the message,
and `info` its info part.

The content of a message is not kept in memory, it is written to disk as soon
at its creation.

```elixir
iex> Maildir.add("/home/doctor/Maildir", "Doctor! We need you!")
{:ok, %Message{maildir: "/home/doctor/Maildir", folder: :new, uniq: "so_uniq_string", info: "2,"}}
```

The library does not assume anything about the content of the file, nor try to
parse the message. That is the job of your e-mail parser.

Thus, creating or adding a message in the maildir will always works, as long as
the content is not the empty string.

You can list all the new message in the Maildir:

```elixir
iex> Maildir.list(my_maildir, :new)
[%Message{...}, %Message{...},...]
iex> Maildir.list(my_maildir, :cur)
[%Message{...}, %Message{...},...]
```

Processing a message move it from `new` to `cur`:

```elixir
iex> Maildir.Message.process(my_message)
:ok
```

And everywhere a function take a message struct as argument, can pass a string
of the message fullpath instead:

```elixir
iex> Maildir.Message.process("/home/doctor/Maildir/new/1111.2ec459f.tardis:2,")
:ok
```

## Steps

1. Implementing the original Maildir specification
1. Implementing the Maildir++ extension
1. Implementing the Dovecot Maildir extension

## Resources

* Wikipedia: https://en.wikipedia.org/wiki/Maildir
* Maildir original specs: http://cr.yp.to/proto/maildir.html
* Maildir original man page: http://www.qmail.org/qmail-manual-html/man5/maildir.html
* Courrier IMAP Maildir++ specs: http://www.courier-mta.org/maildir.html
* Maildir++ quota extension: http://www.courier-mta.org/imap/README.maildirquota.html
* Dovecot maildir implementation: http://wiki2.dovecot.org/MailboxFormat/Maildir
