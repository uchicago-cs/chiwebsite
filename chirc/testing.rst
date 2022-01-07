.. _chirc-testing:

Testing your Implementation
===========================

There are two ways to test your implementation:

#. **Using the provided set of automated tests**. These provide a convenient
   mechanism to verify whether a specific command or set of commands is
   implemented correctly but are harder to debug interactively.
#. **Manually logging into your IRC server**. This will allow you to test your
   implementation more interactively.

Using the automated tests
-------------------------

chirc includes a comprehensive set of automated tests that will allow you to
test whether your implementation is correct. To run the automated tests,
just run one the following from inside the ``build/`` directory::

   make assignment-1
   make assignment-2
   make assignment-3
   make assignment-4
   make assignment-5

Each of the above will build your code, will run all the tests for the
corresponding assignment, and will provide a summary of how many points
you scored in that assignment's tests.

If you've run the tests already, and simply want to print out the points summary
again, you can use the following make target::

   make grade-assignment-N

(where ``N`` is the assignment number)

Invoking py.test directly
~~~~~~~~~~~~~~~~~~~~~~~~~

You can have greater control on what tests are run by invoking py.test directly.
When doing so, you must make sure that you've built the latest version of your
code (using the make targets above will do so automatically, but running
py.test directly will not). We encourage you to always run py.test like this::

    make && py.test <PYTEST OPTIONS>

Where ``<PYTEST OPTIONS>`` are the options described in the sections below.
A few parameters that are useful across the board are the following:

- ``-x``: Stop after the first failed test. This can be useful when you're failing
  multiple tests, and want to focus on debugging one failed test at a time.
- ``-s``: Do not suppress output from successful tests. By default, py.test only
  shows the output produced by chirc if a test fails. In some cases, you may want
  to look at the log messages of a successful test; use this option to force py.test
  to show the output for that test.
- ``--chirc-loglevel N``: This controls the logging level of the chirc server run
  by the tests. You can specify the following values for ``N``:

  - ``-1``: Corresponds to calling chirc with the ``-q`` option.
  - ``0``: Corresponds to the default level of logging.
  - ``1``: Corresponds to calling chirc with the ``-v`` option.
  - ``2``: Corresponds to calling chirc with the ``-vv`` option.


Running categories of tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to run only a specific category of tests, you can use the
``--chirc-category`` parameter. For example::

    py.test --chirc-category PRIVMSG_NOTICE

To see the exact categories available in each assignment, run the following::

    make categories-assignment-N

(where ``N`` is the assignment number)

Running individual tests
~~~~~~~~~~~~~~~~~~~~~~~~

If you want to focus on debugging an individual test that is failing, you can
run a single test by using the ``-k`` parameter::

   py.test -k test_connect_both_messages_at_once
   
The name of each failed test can be found after the ``FAILURES`` line in the output
from the tests. For example::

   ===================================== FAILURES =====================================
   ______________ TestBasicConnection.test_connect_both_messages_at_once ______________

Debugging a test with a debugger
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to debug a test with a debugger, such as gdb, you will have to run chirc separately
from the tests (using the debugger), and then instruct the tests to connect to that server (instead of having the
tests launch chirc on their own).

If using gdb, you would have to run chirc like this::

    gdb --args ./chirc -o foobar -p 7776

This starts chirc using port 7776 (don't forget to then use gdb's ``run`` command
to actually run the server).

Similarly, if using Valgrind, you would have to run chirc like this::

    valgrind ./chirc -o foobar -p 7776

Next, you will use the ``--chirc-external-port PORT`` option to instruct py.test to
use the server you're running with a debugger::

    py.test --chirc-external-port 7776 -k test_connect_both_messages_at_once

Take into account that the ``--chirc-external-port`` only makes sense when running a single
test, so you will also have to use the ``-k`` option to specify what test to run.

Sniffing network traffic during a test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When running an individual test, it can sometimes be useful to take a peek at the exact
messages that are being exchanged between a client and your server.
You can use network sniffers like ``tcpdump`` and Wireshark. The
console version of Wireshark, ``tshark`` can be useful to debug the
automated tests. Take into account that ``tshark``, like Wireshark,
requires special privileges, so you may not be able to run it on your
school's computers and will instead have to run it on your own machine.

By default, py.test will randomize the port that chirc binds to. To force it to
use a specific port, you will need to use the ``--chirc-port PORT`` option.
For example::

   py.test -k test_connect_simple1 --chirc-port=7776
   
Note that we use port 7776 to avoid conflicts with the standard IRC port (6667).
   
On a separate terminal, run ``tshark`` like this::

   tshark -i lo \
          -d tcp.port==7776,irc -Y irc -V -O irc -T fields -e irc.request -e irc.response \
          tcp port 7776

If you then run the test, ``tshark`` should print out the following (assuming
a complete implementation of chirc)::

    NICK user1
    USER user1 * * :User One
        :haddock 001 user1 :Welcome to the Internet Relay Network user1!user1@localhost
        :haddock 002 user1 :Your host is haddock, running version chirc-0.4.4
        :haddock 003 user1 :This server was created 2020-01-05 11:54:02
        :haddock 004 user1 haddock chirc-0.4.4 ao mtov
        :haddock 251 user1 :There are 1 users and 0 services on 1 servers
        :haddock 252 user1 0 :operator(s) online
        :haddock 253 user1 0 :unknown connection(s)
        :haddock 254 user1 0 :channels formed
        :haddock 255 user1 :I have 1 clients and 0 servers
        :haddock 422 user1 :MOTD File is missing


Take into account that the automated tests close the connection as
soon as the test has passed, which means sometimes some messages will
not be sent.



Manually logging into your IRC server
-------------------------------------

The automated tests can be useful to get a sense of what parts of your
project are working correctly, and which ones may need some work. However,
debugging the tests, even with ``tshark``, can be cumbersome since you're
limited by the specific actions that the tests carry out (and check for).

When debugging a specific issue in your server, you can debug it more interactively
by manually connecting to the server using the standard ``telnet`` client. Just
run your server like this::

   ./chirc -o foobar -p 7776
   
And log into it like this::

   telnet localhost 7776
   
This provides a direct interface to the IRC protocol. So, for example, to register
as a user, you would have to type the following into the telnet client::

   NICK user1
   
Pressing the Enter key will send the ``\r\n`` terminator. Next, type this::

   USER user1 * * :User One
   
And press Enter. If your server is correctly implemented, the telnet client will print out the
welcome replies that your server would send in reply to the ``NICK`` and ``USER`` commands. Once
you've logged in like this, you can manually test other IRC commands.

You can also test your implementation with an existing IRC client. We recommend using ``irssi`` (http://irssi.org/), 
which provides a simple terminal-based interface. This will allow you to interact with the IRC protocol
and a higher level (plus, if your server works correctly with a standard IRC client, that is a sign that
your implementation is pretty good). However, take into account that clients like ``irssi`` do not allow you
to type in IRC commands directly (like a telnet session would allow you to). You will need to
use the commands defined in the IRC client (which the IRC client will translate into actual IRC commands
sent over the TCP connection to your server).

