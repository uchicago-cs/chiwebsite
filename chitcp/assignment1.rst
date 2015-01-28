.. _chitcp-assignment1:

Assignment 1: TCP over a Reliable Network
=========================================

This assignment is divided into three main tasks:

-  3-way handshake (40 points)
-  Data transfer (40 points)
-  Connection tear-down (20 points)

In this assignment, you are allowed to assume that the networks is
completely *reliable*. This means that any TCP segment you send is
guaranteed to arrive without delay (chiTCP will ensure this under 
the hood). So, you do not have to worry about retransmissions or
about packets arriving out of order.

Implementing the TCP 3-way handshake
------------------------------------

In ``tcp.c`` you must implement the following:

-  Handling event ``APPLICATION_CONNECT`` in
   ``chitcpd_tcp_state_handle_CLOSED``. This corresponds to handling the
   ``OPEN Call`` in the ``CLOSED STATE`` in
   `[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__.

-  Handling event ``PACKET_ARRIVAL`` in:

   -  ``chitcpd_tcp_state_handle_LISTEN``

   -  ``chitcpd_tcp_state_handle_SYN_SENT``

   -  ``chitcpd_tcp_state_handle_SYN_RCVD``

   As described in the ``SEGMENT ARRIVES`` portion of
   `[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__.

Suggestion: Instead of writing separate pieces of code in each of the handler
functions where you’re handling the ``PACKET_ARRIVAL`` event, you may want to
write a single function whose purpose is to handle packets in any TCP state,
following the general procedure described in pages 64-75 of
`[RFC793] <http://tools.ietf.org/html/rfc793>`__. This will also make it easier
to implement the remaining parts of this assignment

Sending and receiving data
--------------------------

This involves handling the following events in
``chitcpd_tcp_state_handle_ESTABLISHED``:

-  Event ``PACKET_ARRIVAL``, as described in the ``SEGMENT ARRIVES`` portion
   of `[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__, but
   without handling ``FIN`` packets.

-  Event ``APPLICATION_SEND``. This corresponds to handling the ``SEND Call``
   in the ``ESTABLISHED STATE`` in
   `[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__. Take into
   account that the chisocket layer already takes care of putting data in the
   send buffer. So, this event notifies your TCP implementation that there is
   new data in the send buffer, and that it should be sent if possible.

-  Event ``APPLICATION_RECEIVE``. This corresponds to handling the
   ``RECEIVE Call`` in the ``ESTABLISHED STATE`` in
   `[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__. Take into
   account that the chisocket layer already takes care of retrieving data from
   the receive buffer and handing it to the application layer. This event
   notifies your TCP implementation that space has become available in the
   buffer, and you should update the TCP internal variables accordingly.


Connection tear-down
--------------------

This involves handling the ``APPLICATION_CLOSE`` event in the following handlers:

-  ``chitcpd_tcp_state_handle_ESTABLISHED``

-  ``chitcpd_tcp_state_handle_CLOSE_WAIT``

Both of these correspond to handling the ``CLOSE Call`` in the
``ESTABLISHED STATE`` and ``CLOSE-WAIT STATE`` in
`[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__.

You also need to handle the ``PACKET_ARRIVAL`` event in the following handlers:

-  ``chitcpd_tcp_state_handle_FIN_WAIT_1``

-  ``chitcpd_tcp_state_handle_FIN_WAIT_2``

-  ``chitcpd_tcp_state_handle_CLOSE_WAIT``

-  ``chitcpd_tcp_state_handle_CLOSING``

-  ``chitcpd_tcp_state_handle_LAST_ACK``

-  Modify the handling of this event in
   ``chitcpd_tcp_state_handle_ESTABLISHED`` to handle ``FIN`` packets.

All of these are described in the ``SEGMENT ARRIVES`` portion of
`[RFC793 3.9] <http://tools.ietf.org/html/rfc793#section-3.9>`__.

Take into account that, when the application layer requests that a connection be
closed, it does not instantly trigger a TCP connection teardown. Instead, the FIN
packet should be sent *after* all outstanding data in the send buffer has been sent
*and* acknowledged.

In other words, when the ``APPLICATION_CLOSE`` event is received, the connection
teardown should happen only if the send buffer is empty. Otherwise, you should
internally flag the socket as having to be closed once the send buffer is empty.
This could happen if you have sent data, and the ``APPLICATION_CLOSE`` event arrives
while you're still waiting for that data to be ACK'd.

The ``tcp_data_t`` struct already includes a boolean ``closing`` field, but you
are allowed to add additional fields to ``tcp_data_t`` if necessary.


 

 
