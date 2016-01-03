.. _chirc-testing:

Testing your Implementation
===========================

-  If you’re unclear about how your server is meant to behave in some
   cases (specially the more obscure corner cases), take into account
   that there are literally hundreds of production IRC servers on the
   Internet that you can log into to test how they’ve interpreted the
   IRC specification. We suggest using Freenode servers, which you can
   log into simply by running:

   telnet irc.freenode.net 6667

-  Similarly, you can also test your implementation with an existing IRC
   client. We recommend using ``irssi`` (http://irssi.org/), which is
   installed on the CS Linux machines.

-  Finally, it can sometimes be useful to take a peek at the exact
   messages that are being exchanged between a client and your server.
   You can use network sniffers like ``tcpdump`` and Wireshark. The
   console version of Wireshark, ``tshark`` can be useful to debug the
   automated tests. In particular, you can capture the traffic of a test
   (run with ``make singletest``) by running ``tshark`` like this:

   tshark -i lo \\-d tcp.port==7776,irc -R irc -V -O irc -T fields -e
   irc.request -e irc.response \\tcp port 7776

   Note that the automated tests use port 7776 to avoid conflicts with
   the default IRC port (6667), in case you have a server running
   separately from the tests.

   If you run the above during test ``test_connect_basic1``, you should
   see the following:

   NICK user1 USER user1 \* \* :User One :haddock 001 user1 :Welcome to
   the Internet Relay Network user1!user1@localhost.localdomain :haddock
   002 user1 :Your host is haddock, running version chirc-0.1 :haddock
   003 user1 :This server was created 2012-01-02 13:30:04 :haddock 004
   user1 haddock chirc-0.1 ao mtov :haddock 251 user1 :There are 1 users
   and 0 services on 1 servers :haddock 252 user1 0 :operator(s) online
   :haddock 253 user1 0 :unknown connection(s) :haddock 254 user1 0
   :channels formed :haddock 255 user1 :I have 1 clients and 1 servers
   :haddock 422 user1 :MOTD File is missing

   Take into account that the automated tests close the connection as
   soon as the test has passed, which means sometimes some messages will
   not be sent. For example, in this specific test, ``tshark`` may not
   capture any messages after the ``001`` reply.