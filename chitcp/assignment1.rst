.. _chitcp-assignment1:

Assignment 1: TCP over a Reliable Network
=========================================

This assignment is divided into three main tasks:

-  3-way handshake
-  Data transfer
-  Connection tear-down

In this assignment, you are allowed to assume that the network is
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
   `[RFC9293 3.10.1] <https://datatracker.ietf.org/doc/html/rfc9293#name-open-call>`__.

-  Doing an initial implementation of the ``chitcpd_tcp_handle_packet`` function,
   that only covers the arrival of segments in the ``LISTEN``, ``SYN_SENT``, and
   ``SYN_RCVD`` states, as specified in
   `[RFC9293 3.7.10] <https://datatracker.ietf.org/doc/html/rfc9293#name-segment-arrives>`__.


Sending and receiving data
--------------------------

This involves handling the following events in
``chitcpd_tcp_state_handle_ESTABLISHED``:

-  Event ``APPLICATION_SEND``. This corresponds to handling the ``SEND Call``
   in the ``ESTABLISHED STATE`` in
   `[RFC9293 3.10.2] <https://datatracker.ietf.org/doc/html/rfc9293#name-send-call>`__. Take into
   account that the chisocket layer already takes care of putting data in the
   send buffer. So, this event notifies your TCP implementation that there is
   new data in the send buffer, and that it should be sent if possible.

-  Event ``APPLICATION_RECEIVE``. This corresponds to handling the
   ``RECEIVE Call`` in the ``ESTABLISHED STATE`` in
   `[RFC9293 3.10.3] <https://datatracker.ietf.org/doc/html/rfc9293#name-receive-call>`__. Take into
   account that the chisocket layer already takes care of retrieving data from
   the receive buffer and handing it to the application layer. This event
   notifies your TCP implementation that space has become available in the
   buffer, and you should update the TCP internal variables accordingly.

You will also have to complete the implementation of the
``chitcpd_tcp_handle_packet`` function, to handle the arrival of segments in
the ``ESTABLISHED`` state, as specified in
`[RFC9293 3.7.10] <https://datatracker.ietf.org/doc/html/rfc9293#name-segment-arrives>`__.
HOwever, at this point, you can ignore the handing of ``FIN`` packets, as well
as the arrival of packets in the ``FIN_WAIT_1``, ``FIN_WAIT_2``, ``CLOSE_WAIT``,
``CLOSING``, and ``LAST_ACK`` states.

Connection tear-down
--------------------

This involves handling the ``APPLICATION_CLOSE`` event in the following handlers:

-  ``chitcpd_tcp_state_handle_ESTABLISHED``

-  ``chitcpd_tcp_state_handle_CLOSE_WAIT``

Both of these correspond to handling the ``CLOSE Call`` in the
``ESTABLISHED STATE`` and ``CLOSE-WAIT STATE`` in
`[RFC9293 3.10.4] <https://datatracker.ietf.org/doc/html/rfc9293#section-3.10.4>`__.

You also need to complete the implementation of the
``chitcpd_tcp_handle_packet`` function to handle ``FIN`` packets in the
``ESTABLISHED`` state, as well as the arrival of packets in the ``FIN_WAIT_1``, ``FIN_WAIT_2``, ``CLOSE_WAIT``,
``CLOSING``, and ``LAST_ACK`` states, as specified in
`[RFC9293 3.7.10] <https://datatracker.ietf.org/doc/html/rfc9293#name-segment-arrives>`__.

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
 
