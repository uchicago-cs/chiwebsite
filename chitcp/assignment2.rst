.. _chitcp-assignment2:


Assignment 2: TCP over an Unreliable Network
============================================

In this assignment, you will extend the code you wrote for the previous
assignment so that it can work over unreliable networks. In
particular, you must account for the fact that packets could be dropped
by the network layer, or that some packets could be delayed and arrive
out of order.

This assignment is divided into two parts:

- Retransmissions (60 points)
- Out-of-order delivery (40 points)

Retransmissions
---------------

Every time a SYN, data, or FIN segment is sent, you must start a retranmission
timer. If an ACK for that segment is received before the timer expires, then
you must cancel the timeout. If an ACK doesn't arrive, the timer should timeout
and you should resend the segment (and reset the timer).

We suggest you follow this approach:

- Add a *retransmission queue* to the ``tcp_data_t``. Every time a packet is sent,
  add the packet to the restransmission queue, along with any metadata necessary
  to manage the retransmission (such as the time when the packet was sent, and the
  time when it will time out).
  
- When a packet is sent, spawn a *timeout thread* that will generate a ``TIMEOUT``
  event for that socket when the timer expires. chiTCP 
  provides a ``chitcpd_timeout`` function (see :ref:`chitcp-implementing`) that
  will generate this event.
  
  Take into account that, although it is possible to optimize the generation of
  timeouts by cancelling or extending timeouts whenever new data is sent (since the acknowlegement
  of that data will implicitly acknowledge all past data), you are not required
  to do so in this assignment. You can simply have a timeout for each individual
  packet that is sent.
  
- If a packet is ACK'd before the timeout, remove the packet from the retransmission
  queue and cancel its timeout.
  
- Whenever a ``TIMEOUT`` event happens, go through the retransmission queue to check
  what packets (if any) have timed out and need to be re-sent. The provided code
  already includes an (empty) ``if (event == TIMEOUT)`` branch in the handler
  functions where you need to process the ``TIMEOUT`` event.

  As a first approach to your solution, you can resend *only* the package that
  timed out. For full credit, you must implement the go-back-N retransmission scheme: 
  if sequence number N times out, you must resend all the data after sequence number N
  (which requires updating the retransmission queue and timeouts if additional
  packets are being resent).

- You should implement the "classic" RTT estimation formula described in
  `[RFC793 3.7] <http://tools.ietf.org/html/rfc793#section-3.7>`__. However, we
  recommend you start your implementation by setting the RTT to a fixed and
  arbitrarily high value (e.g., one second).
  
- All the above points focus on the peer that sends a packet which is dropped.
  In the other peer, you must remember to only acknowledge the latest sequence
  number *without gaps*. So, if peer A sends packets with sequence numbers 0-99, 
  100-199, and 200-299, and peer B receives only 0-99 and 200-299, you should
  only acknowledge sequence numbers 0-99.
  
  In this part of the assignment, you are allowed to silently drop any packets
  that you cannot immediately acknowledge. So, for example, in the above example,
  peer B would be allowed to drop packet 200-299 (which would be retransmitted
  by peer A). In the next part of the assignment, you will have to account for
  these "gaps" in the received data.


Out-of-order delivery
---------------------

In this part of the assignment, you must account for the fact that there can be
*gaps* in the sequence of bytes you receive. When a sequence of bytes is divided
into multiple packets, these gaps can happen if one or more of the packets are either
dropped or delayed.

The handling of both cases is the same: if you receive a packet that cannot
be immediately acknowledged (because there are gaps in the sequence), you
must buffer those packets until the sequence is complete. Whenever a gap is 
filled, you must send a cumulative ACK of the last byte of contiguous data.

To implement this part, you are allowed to add additional fields to 
the ``tcp_data_t`` struct.

