.. _chirc-testing:

Testing your Implementation
===========================

There are two ways of testing your implementation:

#. **Using the provided set of automated tests**. These provide a convenient
   mechanism to verify whether a specific command or set of commands is
   implemented correctly but are harder to debug interactively.
#. **Manually logging into your IRC server**. This will allow you to test your
   implementation more interactively.

Using the automated tests
-------------------------

chirc includes a comprehensive set of automated tests that will allow you to
test whether your implementation is correct. To run the automated tests,
just run the following::

   make tests
   
This will invoke a testing tool called py.test that will run a series of
individual tests, and will provide a summary of how many tests ran correctly
and how many failed (including the output and error messages for all the
tests that failed). It will also produce an HTML file called ``report.html``
with a summary of the test results.

Running categories of tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~

However, ``make tests`` will run *all* the tests (nearly all
of which will fail when you start working on your project), the output
may not be too useful. The tests are divided into several
categories corresponding to the sections of the three assignments, and you
can run the tests for just one category like this::

   TEST_ARGS="-C CATEGORY" make tests
   
Where ``CATEGORY`` is the category of tests you want to run. All the categories
are listed below:

- Assignment 1

  ::

      TEST_ARGS="-C BASIC_CONNECTION" make tests
      
- Assignment 2

  ::
  
      TEST_ARGS="-C CONNECTION_REGISTRATION" make tests

      TEST_ARGS="-C PRIVMSG_NOTICE" make tests

      TEST_ARGS="-C PING_PONG" make tests

      TEST_ARGS="-C MOTD" make tests

      TEST_ARGS="-C LUSERS" make tests

      TEST_ARGS="-C WHOIS" make tests

      TEST_ARGS="-C ERR_UNKNOWN" make tests

      TEST_ARGS="-C ROBUST" make tests

- Assignment 3

  ::
  
      TEST_ARGS="-C CHANNEL_JOIN" make tests

      TEST_ARGS="-C CHANNEL_PRIVMSG_NOTICE" make tests

      TEST_ARGS="-C CHANNEL_PART" make tests

      TEST_ARGS="-C CHANNEL_TOPIC" make tests

      TEST_ARGS="-C MODES" make tests

      TEST_ARGS="-C AWAY" make tests

      TEST_ARGS="-C NAMES" make tests

      TEST_ARGS="-C LIST" make tests

      TEST_ARGS="-C WHO" make tests

      TEST_ARGS="-C UPDATE_ASSIGNMENT2" make tests      
      
Running individual tests
~~~~~~~~~~~~~~~~~~~~~~~~

If you want to focus on debugging an individual test that is failing, you can also run a single test
by using the ``-k`` parameter::

   TEST_ARGS="-k test_connect_both_messages_at_once" make tests
   
The name of each failed test can be found after the ``FAILURES`` line in the output
from the tests. For example::

   ===================================== FAILURES =====================================
   ______________ TestBasicConnection.test_connect_both_messages_at_once ______________

When running an individual test, it can sometimes be useful to take a peek at the exact
messages that are being exchanged between a client and your server.
You can use network sniffers like ``tcpdump`` and Wireshark. The
console version of Wireshark, ``tshark`` can be useful to debug the
automated tests. Take into account that ``tshark``, like Wireshark,
requires special privileges, so you may not be able to run it on your
school's computers and will instead have to run it on your own machine.

To capture the network traffic from a single test, you will need to run py.test
manually (instead of ``make tests``) to force the tests to use a specific TCP port.
For example, to run the ``test_connect_simple`` test::

   py.test -k test_connect_simple --chirc-port=7776 --chirc-exe=./chirc
   
Note that we use port 7776 to avoid conflicts with the standard IRC port (6667).
   
On a separate terminal, run ``tshark`` like this::

   tshark -i lo \
          -d tcp.port==7776,irc -R irc -V -O irc -T fields -e irc.request -e irc.response \
          tcp port 7776

If you then run the test, ``tshark`` should print out the following (assuming
a complete implementation of chirc)::

   NICK user1  
   USER user1 * * :User One   
      :haddock 001 user1 :Welcome to the Internet Relay Network user1!user1@localhost
      :haddock 002 user1 :Your host is haddock, running version chirc-0.3.9
      :haddock 003 user1 :This server was created 2016-01-03 10:46:01
      :haddock 004 user1 haddock chirc-0.3.9 ao mtov
      :haddock 251 user1 :There are 1 users and 0 services on 1 servers
      :haddock 252 user1 0 :operator(s) online
      :haddock 253 user1 0 :unknown connection(s)
      :haddock 254 user1 0 :channels formed
      :haddock 255 user1 :I have 1 clients and 1 servers
      :haddock 422 user1 :MOTD File is missing

Take into account that the automated tests close the connection as
soon as the test has passed, which means sometimes some messages will
not be sent. For example, in this specific test, ``tshark`` may not

Producing a grade report
~~~~~~~~~~~~~~~~~~~~~~~~

Once you have run all the tests, you can run the following command to produce
a summary of how many tests you are passing, and the points scored on each category
of tests::

   make grade
   
Note: The above command will only produce meaninful output after you've run ``make tests``.

A full implementation of chirc would produce a summary like this::

   Assignment 1
   =========================================================================
   Category                            Passed / Total       Score  / Points    
   -------------------------------------------------------------------------
   Basic Connection                    15     / 15          50.00  / 50.00     
   -------------------------------------------------------------------------
                                                    TOTAL = 50.00  / 50        
   =========================================================================
   
   Assignment 2
   =========================================================================
   Category                            Passed / Total       Score  / Points    
   -------------------------------------------------------------------------
   Connection Registration             5      / 5           35.00  / 35.00     
   PRIVMSG and NOTICE                  10     / 10          30.00  / 30.00     
   PING and PONG                       6      / 6           2.50   / 2.50      
   MOTD                                2      / 2           5.00   / 5.00      
   LUSERS                              7      / 7           10.00  / 10.00     
   WHOIS                               2      / 2           10.00  / 10.00     
   ERR_UNKNOWN                         3      / 3           2.50   / 2.50      
   Robustness                          9      / 9           5.00   / 5.00      
   -------------------------------------------------------------------------
                                                    TOTAL = 100.00 / 100       
   =========================================================================
   
   Assignment 3
   =========================================================================
   Category                            Passed / Total       Score  / Points    
   -------------------------------------------------------------------------
   JOIN                                5      / 5           15.00  / 15.00     
   PRIVMSG and NOTICE to channels      6      / 6           15.00  / 15.00     
   PART                                13     / 13          10.00  / 10.00     
   TOPIC                               10     / 10          10.00  / 10.00     
   User and channel modes              57     / 57          25.00  / 25.00     
   AWAY                                6      / 6           5.00   / 5.00      
   NAMES                               11     / 11          5.00   / 5.00      
   LIST                                5      / 5           5.00   / 5.00      
   WHO                                 6      / 6           5.00   / 5.00      
   Update Assignment 2                 5      / 5           5.00   / 5.00      
   -------------------------------------------------------------------------
                                                    TOTAL = 100.00 / 100       
   =========================================================================

NOTE: The points assigned to each category may not be the ones shown above.
These points are configurable by the instructor, who may decide to allocate
points in different ways.

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

