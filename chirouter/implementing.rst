.. _chirouter-implementing:

Implementation Guide
====================

You are provided with a fair amount of scaffolding code, some of which
you will need to use or modify to implement your router.



As you'll see, you are provided with a *lot* of code. Fortunately, you will
only have to interact with a small portion of it. Most of the provide code
is scaffolding for the chiTCP architecture, which will allow you to focus
on implementing the TCP protocol on a single file: the ``tcp.c`` file.

This implementation guide provides a roadmap for implementing TCP, as well
as a description of header files and functions that you will need to be aware
of as you implement your version of TCP. As a rule of thumb, if a function
is not described here, you probably should not use it in your code.

Implementing RFC 793
--------------------

In this project, you are going to implement a substantial portion of
`[RFC793] <http://tools.ietf.org/html/rfc793>`__. In particular, you will be
focusing on `[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__
(Event Processing), which provides a detailed description of how TCP should
behave (whereas the preceding sections focus more on describing use cases,
header specifications, example communications, etc.). The second paragraph of
this section sums up pretty nicely how a TCP implementation should behave:

::

      The activity of the TCP can be characterized as responding to events.
      The events that occur can be cast into three categories:  user calls,
      arriving segments, and timeouts.  This section describes the
      processing the TCP does in response to each of the events.  In many
      cases the processing required depends on the state of the connection.

So, we can think of TCP as a state machine where:

-  The states are CLOSED, LISTEN, SYN\_SENT, etc.

-  The inputs are a series of events defined in
   `[RFC793] <http://tools.ietf.org/html/rfc793>`__ (we describe these in more
   detail below)

-  The transition from one TCP state to another is based on the current
   state, an event, *and* a series of TCP variables (SND.NXT, SND.UNA, etc.)

-  Transitions from one TCP state to another result in actions, typically
   sending a TCP packet with information dependent on the state of the TCP
   variables and the send/receive buffers.

The events defined in
`[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__ are:

-  ``OPEN``: chiTCP will generate this event when the application layer calls
   ``chisocket_connect``.

-  ``SEND``: chiTCP will generate this event when the application layer calls
   ``chisocket_send``.

-  ``RECEIVE``: chiTCP will generate this event when the application layer
   calls ``chisocket_recv``.

-  ``CLOSE``: chiTCP will generate this event when the application layer
   calls ``chisocket_close``.

-  ``ABORT``: Not supported by chiTCP .

-  ``STATUS``: Not supported by chiTCP .

-  ``SEGMENT ARRIVES``: chiTCP will generate this event when a TCP packet
   arrives.

-  ``USER TIMEOUT``: Not supported by chiTCP .

-  ``RETRANSMISSION TIMEOUT``: A retransmission timeout (set after sending a
   packet) has expired, meaning that an ACK for that packet has not been
   received.

-  ``TIME-WAIT TIMEOUT``: Not supported by chiTCP .

As described in the next section, your work in chiTCP will center mostly on a
file called ``tcp.c`` where you are provided with functions that handle events
in given TCP states. These functions are initially mostly empty, and it is up
to you to write the code that will handle each event in each state.

Of course, a TCP implementation would have to consider every possible
combination of states and events. However, many of these are actually invalid
combinations. For example,
`[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__ specifies that
that if the ``SEND`` event happens in the following states:

::

        FIN-WAIT-1 STATE
        FIN-WAIT-2 STATE
        CLOSING STATE
        LAST-ACK STATE
        TIME-WAIT STATE

Then the following action must be taken:

::

          Return "error:  connection closing" and do not service request.

Actions like this are actually handled in the chisocket layer, and you will not
have to worry about them. For example, in the above case, the
``chisocket_send`` function will set ``errno`` to ``ENOTCONN``.

Sections :ref:`chitcp-assignment1` and :ref:`chitcp-assignment2` carve out
exactly what state/event combinations you will have to implement. Additionally,
your implementation should take the following into account:

-  You do not need to support delayed acknowledgements. An acknowledgement
   packet is sent immediately when data is received, although you can piggyback
   any data in the send buffer that is waiting to be sent (but you do not need
   to wait for a timeout to increase the probability that you’ll be able to
   piggyback data on the acknowledgement).

-  You do not need to support the ``RST`` bit.

-  You do not need to support the ``PSH`` bit.

-  You do not need to support the Urgent Pointer field or the ``URG`` bit in
   the TCP header. This also means you do not need to support the ``SND.UP``,
   ``RCV.UP``, or ``SEG.UP`` variables.

-  You do not need to support TCP’s "security/compartment" features, which
   means you can assume that ``SEG.PRC`` and ``TCB.PRC`` always have valid and
   correct values.

-  You do not need to support the checksum field of the TCP header.

-  You do not need to support TCP options.

-  You do not need to support the ``TIME_WAIT`` timeout. You should still
   update the TCP state to ``TIME_WAIT`` when required, but do not have to
   implement a timeout. Instead, you should immediately transition to
   ``CLOSED`` from the ``TIME_WAIT`` state.

-  You do not need to support simultaneous opens (i.e., the transition from
   ``SYN_SENT`` to ``SYN_RCVD``).


Implementing the ``tcp.c`` file
-------------------------------

Since TCP is essentially a state machine, chiTCP ’s implementation boils down to
having a handler function for each of the TCP states (CLOSED, LISTEN,
SYN\_RCVD, etc.), all contained in the ``src/chitcpd/tcp.c`` file. If an event
happens (e.g., a packet arrives) while the connection is in a specific state
(e.g., ESTABLISHED), then the handler function for that state is called, along
with information about the event that just happened. You will only have to
worry about writing the code inside the handler function; the rest of the
scaffolding (the socket library, the actual dispatching of events to the state
machine, etc.) is already provided for you.

Each handler function has the following prototype:

.. code-block:: c

    int chitcpd_tcp_state_handle_STATENAME(serverinfo_t *si, 
                                           chisocketentry_t *entry, 
                                           tcp_event_type_t event);

The parameters to the function are:

-  ``si`` is a pointer to a struct with the chiTCP daemon’s runtime
   information (e.g., the socket table, etc.). You should not need to access or
   modify any of the data in that struct, but you will need the ``si`` pointer
   to call certain auxiliary functions.

-  ``entry`` is a pointer to the socket entry for the connection that is
   being handled. The socket entry contains the actual TCP data (variables,
   buffers, etc.), which can be accessed like this:

   .. code-block:: c

        tcp_data_t *tcp_data = &entry->socket_state.active.tcp_data;
        

   The contents of the ``tcp_data_t`` struct are described below. 
   
   ``entry`` also contains the value of the TCP state (SYN_SENT, ESTABLISHED, etc.)
   in the ``tcp_state`` variable:

   .. code-block:: c

        tcp_state_t tcp_state = entry->tcp_state;
      
   Since each handler function corresponds to a specific state, you ordinarily
   will not need to access this variable. However, if you write an auxiliary
   function that needs to check a socket's current state, you can obtain the 
   state via the ``tcp_state`` variable. Take into account that you should
   *never* modify that variable directly. You should only modify it using the
   ``chitcpd_update_tcp_state`` function described below. 
   
   Other than the TCP data and the TCP state, you should
   not access or modify any other information in ``entry``.

-  ``event`` is the event that is being handled. The list of possible events
   corresponds roughly to the ones specified in
   `[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__. They are:

   -  ``APPLICATION_CONNECT``: Application has called
      ``chisocket_connect()`` and a three-way handshake must be initiated.

   -  ``APPLICATION_SEND``: Application has called ``chisocket_send()``.
      The socket layer (which is already implemented for you) already takes
      care of placing the data in the socket’s TCP send buffer. This event is a
      notification that there may be new data in the send buffer, which should
      be sent if possible.

   -  ``APPLICATION_RECEIVE``: Application has called
      ``chisocket_recv()``. The socket layer already takes care of extracting
      the data from the socket’s TCP receive buffer. This event is a
      notification that there may now be additional space available in the
      receive buffer, which would require updating the socket’s receive window
      (and the advertised window).

   -  ``APPLICATION_CLOSE``: Application has called ``chisocket_close()``
      and a connection tear-down should be initiated once all outstanding data
      in the send buffer has been sent.

   -  ``PACKET_ARRIVAL``: A packet has arrived through the network and
      needs to be processed (RFC 793 calls this “SEGMENT ARRIVES”)

   -  ``TIMEOUT``: A timeout (e.g., a retransmission timeout) has happened.

To implement the TCP protocol, you will need to implement the handler functions
in ``tcp.c``. You should not need to modify any other file. However, you will
need to use a number of functions and structs defined elsewhere.

The ``tcp_data_t`` struct
-------------------------

This struct contains all the TCP data for a given socket. It is also useful to
think of this struct as the "Transmission Control Block" for a given connection.

The pending packet queue
    .. code-block:: c

        list_t pending_packets;
        pthread_mutex_t lock_pending_packets;
        pthread_cond_t cv_pending_packets;

    As TCP packets arrive through the network, the chiTCP daemon places them
    in the pending packet queue of the appropriate socket (you do not need to
    inspect the origin and destination port of the TCP packet; this is taken
    care of for you). The list contains pointers to ``tcp_packet_t`` structs
    (described below) in the heap. It is your responsibility to free this
    memory when you are done processing a packet.

    The queue is implemented with the SimCList library, which is already
    included in the chiTCP code, and the head of the queue can be retrieved
    using SimCList’s ``list_fetch`` function. The ``lock_pending_packets``
    mutex provides thread-safe access to the queue. The ``cv_pending_packets``
    condition variable is used to notify other parts of the chiTCP code that
    there are new packets in the queue; you should not wait or signal this
    condition variable.

The TCP variables
    .. code-block:: c

        /* Send sequence variables */
        uint32_t ISS;      /* Initial send sequence number */
        uint32_t SND_UNA;  /* First byte sent but not acknowledged */
        uint32_t SND_NXT;  /* Next sendable byte */
        uint32_t SND_WND;  /* Send Window */
    
        /* Receive sequence variables */
        uint32_t IRS;      /* Initial receive sequence number */
        uint32_t RCV_NXT;  /* Next byte expected */
        uint32_t RCV_WND;  /* Receive Window */

    These are the TCP sequence variables as specified in
    `[RFC793 3.2] <http://tools.ietf.org/html/rfc793#section-3.2>`__.

The TCP buffers
    .. code-block:: c

        circular_buffer_t send; 
        circular_buffer_t recv;

    These are the TCP send and receive buffers for this socket. The
    ``circular_buffer_t`` type is defined in the ``include/chitcp/buffer.h``
    and ``src/libchitcp/buffer.c`` files. 

    The management of these buffers is already partially implemented:

    -  The ``chisocket_send()`` function places data in the send buffer
       and generates an ``APPLICATION_SEND`` event.

    -  The ``chisocket_recv()`` function extracts data from the receive
       buffer and generates an ``APPLICATION_RECV`` event.

    In other words, you do not need to implement the above functionality; it
    is already implemented for you. On the other hand, you will be responsible
    for the following:

    -  When an ``APPLICATION_SEND`` event happens, you must check the
       send buffer to see if there is any data ready to send, and you must send
       it out if possible (i.e., if allowed by the send window).

    -  When a ``PACKET_ARRIVAL`` event happens (i.e., when the peer sends
       us data), you must extract the packets from the pending packet queue,
       extract the data from those packets, verify that the sequence numbers
       are correct and, if appropriate, put the data in the receive buffer.

    -  When an ``APPLICATION_RECV`` event happens, you do not need to
       modify the receive buffer in any way, but you do need to check whether
       the size of the send window should be adjusted.

The withheld packet queue
    .. code-block:: c

        list_t withheld_packets; 
        pthread_mutex_t lock_withheld_packets;

    This list is used internally to simulate delayed packets. You do
    not need to use or modify this queue in any way.

The ``tcp_packet_t`` struct
---------------------------

The ``tcp_packet_t`` struct is used to store a single TCP packet:

.. code-block:: c

    typedef struct tcp_packet
    {
        uint8_t *raw;
        size_t  length;
    } tcp_packet_t;

This struct simply contains a pointer to the packet in the heap, along with its
total length (including the TCP header). You will rarely have to work with the
TCP packet directly at the bit level. Instead, the ``include/chitcp/packet.h``
header defines a number of functions, macros, and structs that you can use to
more easily work with TCP packets. More specifically:

-  Use the ``TCP_PACKET_HEADER`` to extract the header of the packet (with
   type ``tcphdr_t``, also defined in ``include/chitcp/packet.h``, which
   provides convenient access to all the header fields. Take into account that
   all the values in the header are in network-order: you will need to convert
   them to host-order before using using (and viceversa when creating a packet
   that will be sent to the peer).

-  Use the ``TCP_PAYLOAD_START`` and ``TCP_PAYLOAD_LEN`` macros to obtain a
   pointer to the packet’s payload and its length, respectively.

-  Use the ``SEG_SEQ``, ``SEG_ACK``, ``SEG_LEN``, ``SEG_WND``, ``SEG_UP``
   macros to access the ``SEG.``\ \* variables defined in `[RFC793 3.2]
   <http://tools.ietf.org/html/rfc793#section-3.2>`__. Take into account that these macros *do* convert the values from network-order to host-order.

-  Finally, although this header file provides a ``chitcp_tcp_packet_create``
   function, you should not use this function directly. Instead, use
   ``chitcpd_tcp_packet_create`` (note the ``chitcpd`` prefix, not ``chitcp``)
   defined in ``src/chitcpd/serverinfo.h``, which is a wrapper around
   ``chitcp_tcp_packet_create`` (besides creating a packet, it will also
   correctly initialize the source and destination ports to match those of the
   socket).

The ``chitcpd_update_tcp_state`` function
-----------------------------------------

This function is defined in ``src/chitcpd/serverinfo.h``. Whenever you need to
change the TCP state, you must use this function. For example:

.. code-block:: c

    chitcpd_update_tcp_state(si, entry, ESTABLISHED);

The ``si`` and ``entry`` parameters are the same ones that are passed to the TCP
handler function.

The ``chitcpd_send_tcp_packet`` function
----------------------------------------

This function is defined in ``src/chitcpd/connection.h``. Whenever you need to
send a TCP packet to the socket’s peer, you must use this function. For example:

.. code-block:: c

    tcp_packet_t packet;

    /* Initialize values in packet */

    chitcpd_send_tcp_packet(si, entry, &packet);

The ``si`` and ``entry`` parameters are the same ones that are passed to the TCP
handler function.

The ``chitcpd_timeout`` function
--------------------------------

This function is defined in ``src/chitcpd/serverinfo.h``. This function will
generate a ``TIMEOUT`` event for a given socket:

.. code-block:: c

    chitcpd_timeout(si, entry);

The ``si`` and ``entry`` parameters are the same ones that are passed to the TCP
handler function.

The logging functions
---------------------

The chiTCP daemon prints out detailed information to standard output using a
series of logging functions declared in ``src/include/log.h``. We encourage you
to use these logging functions instead of using ``printf`` directly. More
specifically, you should use the printf-style ``chilog()`` function to print
messages:

.. code-block:: c

    chilog(WARNING, "Asked send buffer for %i bytes, but got %i.", nbytes, tosend);

And the ``chilog_tcp()`` function to dump the contents of a TCP packet:

.. code-block:: c

    tcp_packet_t packet;

    /* Initialize values in packet */

    chilog(DEBUG, "Sending packet...");
    chilog_tcp(DEBUG, packet, LOG_OUTBOUND);
    chitcpd_send_tcp_packet(si, entry, &packet);

The third parameter of ``chilog_tcp`` can be ``LOG_INBOUND`` or ``LOG_OUTBOUND``
to designate a packet that is being received or sent, respectively (this
affects the formatting of the packet in the log). ``LOG_NO_DIRECTION`` can also
be used to indicate that the packet is neither inbound nor outbound.

In both functions, the first parameter is used to specify the log level:

-  ``CRITICAL``: Used for critical errors for which the only solution is to
   exit the program.

-  ``ERROR``: Used for non-critical errors, which may allow the program to
   continue running, but a specific part of it to fail (e.g., an individual
   socket).

-  ``WARNING``: Used to indicate unexpected situation which, while not
   technically an error, could cause one.

-  ``INFO``: Used to print general information about the state of the program.

-  ``DEBUG``: Used to print detailed information about the state of the
   program.

-  ``TRACE``: Used to print low-level information, such as function
   entry/exit points, dumps of entire data structures, etc.

The level of logging is controlled by the ``-v`` argument when running
``chitcpd``:

-  No ``-v`` argument: Print only ``CRITICAL`` and ``ERROR`` messages.

-  ``-v``: Also print ``WARNING`` and ``INFO`` messages.

-  ``-vv``: Also print ``DEBUG`` messages.

-  ``-vvv``: Also print ``TRACE`` messages.
