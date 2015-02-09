.. _chitcp-testing:

Testing your Implementation
===========================

We provide a number of automated tests and tools that you can use to
test your implementation.

Automated tests
---------------

You can run the chiTCP automated tests by running this::

    make check

You can control the level of logging when running the checks by passing a
``LOG`` option to ``make``. For example, to print all ``DEBUG`` messages, run
this::

    make check LOG=DEBUG

You do *not* need to run ``chitcpd`` for the tests to run. The tests automatically
launch a chiTCP daemon during the tests.

Running tests selectively
-------------------------

The entire test suite can take a long time to run, specially when you start working
on the project, since most of the tests will time out. You can run individual groups
of tests like this:

* TCP connection establishment::

    CK_RUN_CASE="3-way handshake" make check
  
* TCP connection termination::

    CK_RUN_CASE="Connection termination" make check

* TCP data transfer::

    CK_RUN_CASE="Client sends, Server receives" make check
    CK_RUN_CASE="Echo" make check

* TCP over an unreliable network::

    CK_RUN_CASE="Dropped packets" make check
    CK_RUN_CASE="Out of order packets" make check


Echo server and client
----------------------

When the automated tests fail, it can be hard to see exactly what went wrong,
even when using the ``LOG`` option. When you start developing your TCP
implementation, we suggest you use the ``echo-server`` and ``echo-client``
sample programs found in the ``samples`` directory. You can build these samples
by running::

    make samples

``echo-server`` and ``echo-client`` are a basic implementation of an echo server
and client. The echo server creates a passive socket on port 7 and, when a
client connects on that port, every byte the client sends will be sent back
verbatim. It is a simple way of testing that basic operations, like connecting
or sending small messages, work correctly.

Take into account that ``echo-server`` and ``echo-client`` both use the *chisocket*
library. This means that you **must** run ``chitcpd`` on the same machine you're running
``echo-server`` and ``echo-client``. Otherwise, the chisocket library will not work.

When testing with these applications, we suggest you run ``chitcpd`` with option
``-vv``. This will print detailed output about what your TCP implementation is
doing, including changes in the TCP variables. Additionally, you can run
``echo-server`` and ``echo-client`` with a ``-s`` option that will allow you to
"step through" the stages of the TCP connection. For example, if you run
``echo-server -s``, you should step through the following::

    Press any key to create the socket...
    Press any key to bind the socket...
    Press any key to make the socket listen...
    Press any key to accept a connection...

After that last message, the server will block, waiting for connections.

Then, run ``echo-client -s`` and step through the following::

    Press any key to create the socket...
    Press any key to connect to the server... 

As your TCP implementation sends and receives the packets for the three-way
handshake, you should see several messages appear on the ``chitcpd`` log. For
example, if you are sending the SYN packet correctly from the client to the
server, you should see something like this::

     >>> Handling event APPLICATION_CONNECT on state CLOSED
     >>> TCP data BEFORE handling:
        ......................................................
                              CLOSED
     
                 ISS:           0           IRS:           0
             SND.UNA:           0 
             SND.NXT:           0       RCV.NXT:           0 
             SND.WND:           0       RCV.WND:           0 
         Send Buffer:    0 / 4096   Recv Buffer:    0 / 4096
     
            Pending packets:    0    Closing? NO
        ......................................................
     <<< TCP data AFTER handling:
        ......................................................
                              SYN_SENT
     
                 ISS:          27           IRS:           0
             SND.UNA:          27 
             SND.NXT:          28       RCV.NXT:           0 
             SND.WND:           0       RCV.WND:        4096 
         Send Buffer:    0 / 4096   Recv Buffer:    0 / 4096
     
            Pending packets:    0    Closing? NO
        ......................................................

Please note that the actual values of the TCP variables will probably be
different. To make this output even more useful, you may want to use
``chilog_tcp`` to print out the contents of (1) any TCP packet you send, and
(2) any TCP packets you extract from the ``pending_packets``. If you do this,
the output of ``chitcpd`` would look like this:

::

     >>> Handling event APPLICATION_CONNECT on state CLOSED
     >>> TCP data BEFORE handling:
        ......................................................
                              CLOSED
     
                 ISS:           0           IRS:           0
             SND.UNA:           0 
             SND.NXT:           0       RCV.NXT:           0 
             SND.WND:           0       RCV.WND:           0 
         Send Buffer:    0 / 4096   Recv Buffer:    0 / 4096
     
            Pending packets:    0    Closing? NO
        ......................................................
     Sending TCP packet
        ######################################################################
     >  Src: 49152  Dest: 7  Seq: 27  Ack: 0  Doff: 5  Win: 4096
     >  CWR: 0  ECE: 0  URG: 0  ACK: 0  PSH: 0  RST: 0  SYN: 1  FIN: 0
     >  No Payload
        ######################################################################
     <<< TCP data AFTER handling:
        ......................................................
                              SYN_SENT
     
                 ISS:          27           IRS:           0
             SND.UNA:          27 
             SND.NXT:          28       RCV.NXT:           0 
             SND.WND:           0       RCV.WND:        4096 
         Send Buffer:    0 / 4096   Recv Buffer:    0 / 4096
     
            Pending packets:    0    Closing? NO
        ......................................................

If the connection is established correctly, you should see this on the echo
server:

::

    Got a connection from 127.0.0.1:49152

And the following on the echo client:

::

    echo> 

Now, if you type something and press Enter, and data transmission is correctly
implemented, you should get a copy of the message back:

::

    echo> Hello, world!
    Hello, world!

If you do not get the same message back, an error message will be printed.

To close the connection on the client side, just press Control+D. You will see
the following message:

::

    Press any key to close connection...

After pressing a key, an active close will be initiated by the client, which
will send a ``FIN`` packet to the server. You will then see this on the server
side:

::

    Peer has closed connection.
    Press any key to close active socket...

This means the client has closed its side of the connection, but the server has
not. If you press any key, the server will send a ``FIN`` to the client. You
will then see this on the server:

::

    Active socket closed.
    Press any key to close passive socket...

Once you press any key, this will make the server stop listening on port 7.

Finally, both the client will prompt you to press any key to exit:

::

    Press any key to exit...
    

The "simple tester"
-------------------

The echo client and server can still be cumbersome for testing since they require
running three different programs (chitcpd, echo-server, and echo-client) and staying
on top of how each of them behaves.

So, we have an additional sample program that runs a server and client simultaneously.
The client connects to the server, sends a single message, and then both of them initiate
a simultanous tear-down. This sample program is built along with the echo client/server
samples by running this::
   
    make samples

To run it, make sure ``chitcpd`` is running (with option ``-vv`` as suggested earlier) and
then just run this from the ``samples`` directory::

    ./simple-tester

Assuming a correct TCP implementation, the simple tester will print out every TCP state
transition during the communication, as well as the value of the TCP variables::

    Socket 1: [SND.UNA =   225  SND.NXT =   226  RCV.NXT =     0]              ->     SYN_SENT
    Socket 2: [SND.UNA =    99  SND.NXT =   100  RCV.NXT =   226]              ->     SYN_RCVD
    Socket 1: [SND.UNA =   226  SND.NXT =   226  RCV.NXT =   100]     SYN_SENT ->  ESTABLISHED
    Socket 2: [SND.UNA =   100  SND.NXT =   100  RCV.NXT =   226]     SYN_RCVD ->  ESTABLISHED
    Socket 1: Sent 'Hello, chiTCP!'
    Socket 2: Recv 'Hello, chiTCP!'
    Socket 1: [SND.UNA =   226  SND.NXT =   240  RCV.NXT =   100]  ESTABLISHED ->   FIN_WAIT_1
    Socket 2: [SND.UNA =   100  SND.NXT =   100  RCV.NXT =   240]  ESTABLISHED ->   FIN_WAIT_1
    Socket 1: [SND.UNA =   240  SND.NXT =   241  RCV.NXT =   101]   FIN_WAIT_1 ->      CLOSING
    Socket 2: [SND.UNA =   100  SND.NXT =   101  RCV.NXT =   241]   FIN_WAIT_1 ->      CLOSING
    Socket 1: [SND.UNA =   241  SND.NXT =   241  RCV.NXT =   101]      CLOSING ->    TIME_WAIT
    Socket 2: [SND.UNA =   101  SND.NXT =   101  RCV.NXT =   241]      CLOSING ->    TIME_WAIT
    Socket 1: [SND.UNA =   241  SND.NXT =   241  RCV.NXT =   101]    TIME_WAIT ->       CLOSED
    Socket 2: [SND.UNA =   101  SND.NXT =   101  RCV.NXT =   241]    TIME_WAIT ->       CLOSED

Socket 1 is the active opener, and Socket 2 is the passive opener (note: sometimes the active
opener will get Socket 0). Although you may see different values for the Initial Sequence Number, 
the relative progression of the TCP variables should be the same. Similarly, the order of the 
state transitions may be slightly different than shown above.

    
Wireshark dissector
-------------------

We provide a Wireshark dissector, in the ``wireshark_dissector`` directory,
that you can use to easily see what is *actually* sent through the network 
during a chiTCP connection.

To install the dissector, follow these steps:

1. Make sure Lua with support for the "bit" library is installed. On
   Ubuntu, this requires installing the following packages::

     lua5.2
     lua-bitop

2. Copy the file ``chitcp.lua`` to ``~/.wireshark/plugins``

3. Lua plugins will not work if Wireshark is run as root. You will need
   to give your user permissions to perform network captures without
   having root privileges. If you are on a Debian/Ubuntu system, just
   follow these instructions:

     http://ask.wireshark.org/questions/7523/ubuntu-machine-no-interfaces-listed

   For other systems, there are general instructions here:

     http://wiki.wireshark.org/CaptureSetup/CapturePrivileges

Using the dissector
^^^^^^^^^^^^^^^^^^^

Since, as far as Wireshark is concerned, the ChiTCP packet is application-level
data, we need to use a specific port so Wireshark will know what TCP packets
contain ChiTCP packets. The default is 23300, although this can be changed
in ``chitcp.lua``.

Wireshark should automatically detect the new dissector. If you capture TCP
packets, it should flag non-empty packets on port 23300 as ChiTCP packets. You
should be able to see the ChiTCP header fields in human-readable format right
below the TCP packet data. Wireshark will also helpfully dissect *your* TCP packet
as well as its payload.

For example, this is what wireshark should look like if you use the sample echo
server/client:

.. figure:: wireshark.png
   :alt: Wireshark running chiTCP dissector
   
   Wireshark running chiTCP dissector

Note how you can also apply the filter ``chitcp``, and that will show only the
TCP packets that contain ChiTCP packets.

    
