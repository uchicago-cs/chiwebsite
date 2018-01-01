.. _chitcp-assignment2:


Assignment 2: TCP over an Unreliable Network
============================================

In this assignment, you will extend the code you wrote for the previous
assignment so that it can work over unreliable networks. In
particular, you must account for the fact that packets could be dropped
by the network layer, or that some packets could be delayed and arrive
out of order.

This assignment is divided into two parts:

- Retransmissions
- Out-of-order delivery

Retransmissions
---------------

You must add a per-socket *retransmission timer* (implemented with a single
thread) that is managed in the manner described in `[RFC6298 § 5] <https://tools.ietf.org/html/rfc6298#section-5>`__.
The RTO (Retransmission TimeOut) should be computed as specified in  `[RFC6298 § 2-4] <https://tools.ietf.org/html/rfc6298#section-2>`__.

Please note the following:

- We will assume a clock granularity of 1 millisecond (the same granularity used in Linux).
  Given how chiTCP is implemented, the clock granularity is somewhat meaningless
  (it refers to how often the TCP timers are updated internally, which is
  not the approached followed in chiTCP; in an operating system kernel,
  an interrupt would happen every millisecond to update the values of
  certain TCP timers). However, we need to plug in a granularity in some of
  the formulas in the RFC, so we might as well use the one in Linux.
- You must implement go-back-N so, in `[RFC6298 § 5.4] <https://tools.ietf.org/html/rfc6298#section-5>`__,
  you should retransmit the earliest segment that has not been acknowledged,
  *and* all subsequent unacknowledged segments.
- You do not need to implement section 5.7

We suggest you follow this approach:

- Add a *retransmission queue* to the ``tcp_data_t``. Every time a packet is sent,
  add the packet to the restransmission queue, along with any metadata necessary
  to manage the retransmission (such as the time when the packet was sent). You may
  also add other fields to ``tcp_data_t``.
  
- Spawn the retransmission timer thread in ``tcp_data_init`` (in tcp.c).
  You should implement your thread function so that it can be in at least two states:
  stopped or running. Please note that this can be done without killing or cancelling 
  the thread itself. Instead, it should be possible for you to signal the thread,
  so that it can reevaluate whether it needs to change its state. 
  
  When the threads times out (i.e., when it runs for RTO seconds without anything
  happening that would cancel the timer), you must generate a ``TIMEOUT`` event
  by calling ``chitcpd_timeout``. The handling of the timeout should happen
  in your TCP state handlers; *do not implement the retransmission logic
  in your retransmission timer thread*. The purpose of this thread is purely
  to act as a timer.
  
- Whenever a ``TIMEOUT`` event happens, go through the retransmission queue to check
  what packets need to be re-sent. The provided code
  already includes an (empty) ``if (event == TIMEOUT)`` branch in the handler
  functions where you need to process the ``TIMEOUT`` event.

- When a packet is acknowledged, don't forget to remove it from the retranmission queue.
  Since a TCP packet could acknowledge multiple packets at once, you must make
  sure to traverse the retransmission queue in case there are multiple packets
  that should be removed.
  
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

