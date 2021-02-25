.. _chitcp-assignment2:


Assignment 2: TCP over an Unreliable Network
============================================

In this assignment, you will extend the code you wrote for the previous
assignment so that it can work over unreliable networks. In
particular, you must account for the fact that packets could be dropped
by the network layer, or that some packets could be delayed and arrive
out of order.

Doing so will require using *timers*. A timer is mechanism that allows
a certain action to be scheduled to happen at some point in the future
(when this happens, the timer is said to "expire" or "time out", and the action
associated with that timer will be performed). TCP relies on several
timers to deal with unreliable networks, but we will focus only on two:

- The *retransmission timer*. This timer will expire whenever so much time
  has passed since sending a segment (and not receiving an ACK for that
  segment) that we can consider that segment effectively dropped. When
  this happens, the segment will need to be retransmitted.
- The *persist timer*. This timer is used to periodically send "probe segments"
  to a host that is advertising a window of size zero, to force that
  host to send the latest value of its window.

So, this assignment is divided into four parts:

- Implementing a timer API
- Managing a retransmission timer
- Sending probe segments with a persist timer
- Out-of-order delivery

Implementing a Timer API
------------------------

Before we can implement the TCP timers, we will implement a general-purpose
timer mechanism. More specifically, we have defined an API in ``include/chitcp/multitimer.h``
with the operations required to manage multiple timers (since we will have to
work with two timers in TCP: the retransmission timer and the persist timer).
We have also provided an extensive set of tests for this API.

You must implement the API's functions in the ``src/libchitcp/multitimer.c`` file,
ensuring they behave as described in the function headers for each API function.
While implementing these functions, please note the following:

- You cannot use busy waiting or the ``sleep`` or ``usleep`` functions to implement
  the timer mechanism. We recommend you use condition variables instead.
- While a "multitimer" supports multiple timers, your implementation must use a
  *single* thread to manage all the timers. You cannot create a separate thread
  per timer.
- Furthermore, while this thread can be blocked (e.g., by waiting on a condition
  variable), it should not exit until the multitimer is freed. In other words,
  you should never have to kill and re-create your timer thread.
- You are allowed to add fields to the ``single_timer_t`` and ``multi_timer_t`` structs.
  Do not remove or rename any of the fields already included in ``single_timer_t``.
- You are allowed to add additional functions to the API, but please note that the functions
  included in the API should already be enough to implement retransmission timers and
  persist timers in TCP. In particular, take into account that "resetting" a timer is
  effectively just a cancel operation followed by setting the timer again.
- You are not required to implement ``mt_chilog`` or ``mt_chilog_single_timer``, but
  we encourage you to do so, as these functions will come in handy when debugging your code.


Retransmissions
---------------

You will use the Timer API to manage a retransmission timer in the manner described in `[RFC6298 § 5] <https://tools.ietf.org/html/rfc6298#section-5>`__.
The RTO (Retransmission TimeOut) should be computed as specified in  `[RFC6298 § 2-4] <https://tools.ietf.org/html/rfc6298#section-2>`__.

Please note the following:

- We will assume a clock granularity of 50 milliseconds. Furthermore, while the RFC requires
  that the RTO always be at least one second, we will instead use a minimum RTO of 200 milliseconds.
- You must implement go-back-N so, in `[RFC6298 § 5.4] <https://tools.ietf.org/html/rfc6298#section-5>`__,
  you should retransmit the earliest segment that has not been acknowledged,
  *and* all subsequent unacknowledged segments.
- You do not need to implement section 5.7

We suggest you follow this approach:

- Add a multitimer to the ``tcp_data_t`` struct. Initialize it in ``tcp_data_init`` 
  and free it in ``tcp_data_free`` (in tcp.c).

- Add a *retransmission queue* to the ``tcp_data_t`` struct. Every time a packet is sent,
  add the packet to the restransmission queue, along with any metadata necessary
  to manage the retransmission (such as the time when the packet was sent). You may
  also add other fields to ``tcp_data_t``.
  
- The callback function to the timer must generate a ``TIMEOUT_RTX`` event
  by calling ``chitcpd_timeout`` (with the ``type`` parameter set to ``RETRANSMISSION``).
  The handling of the timeout should happen
  in your TCP state handlers; *do not implement the retransmission logic
  in your callback function!*.
  
- Whenever a ``TIMEOUT_RTX`` event happens, go through the retransmission queue to check
  what packets need to be re-sent. The provided code
  already includes an (empty) ``if (event == TIMEOUT_RTX)`` branch in the handler
  functions where you need to process the ``TIMEOUT_RTX`` event.

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
  by peer A). In the last part of the assignment, you will have to account for
  these "gaps" in the received data.


Persist timer
-------------

When a receiving host advertises a window of size zero,
the sending host cannot send anything until the advertised window becomes
non-zero. While the receiving host can send an ACK with an updated window
value whenever its window becomes non-zero, that ACK could be dropped in
an unreliable network.

So, the proper way to deal with this is by periodically sending a *probe segment*
to the receiving host, meant to elicit an ACK that provides the latest 
window value. The sending of this proble segment is handled via a *persist timer*
that will operate as follows:

- When a segment is received with SEG.WND=0 (i.e., the advertised window is zero),
  set the persist timer to expire after RTO seconds.
- If a segment is received with SEG.WND>0 *before* the timer expires, then
  cancel the timer.
- If the timer expires, and there is currently no data to send (i.e., if the
  send buffer is empty), reset the timer to expire after RTO seconds.
- If the timer expires, and there is data to send, then send a probe segment with 
  a single byte of data from the send buffer. Reset the timer to expire after
  RTO seconds. Careful: you must still update SND.NXT.
- If the timer expires again, you must send a probe segment with the same byte of
  data. While you could use the retransmission queue for this, we suggest you manage
  this probe segment separately (in other words, we recommend you do *not* add the
  probe segments to the retransmission queue)

Note: While `[RFC1122 § 4.2.2.17] <https://tools.ietf.org/html/rfc1122#section-4.2.2.17>`__
suggests increasing the persist timer exponentially, we will not do so here.

We suggest you follow this approach:

- Modify ``tcp_data_init`` (in tcp.c) so your multimer will have two timers instead of one.
- Modify your packet arrival handler to set the persist timer when a zero window is received,
  and to cancel it when a non-zero window is received.
- The callback function to the timer must generate a ``TIMEOUT_PST`` event
  by calling ``chitcpd_timeout`` (with the ``type`` parameter set to ``PERSIST``).
  The handling of the timeout should happen
  in your TCP state handlers; *do not implement the persist timer logic
  in your callback function!*.
- Whenever a ``TIMEOUT_PST`` event happens, perform the actions described above
  (when the timer expires)


Out-of-order delivery
---------------------

In this part of the assignment, you must account for the fact that there can be
*gaps* in the sequence of bytes you receive. When a sequence of bytes is divided
into multiple packets, these gaps can happen if one or more of the packets are either
dropped or delayed.

The handling of both cases is the same: if you receive a packet that cannot
be immediately acknowledged (because there are gaps in the sequence), you
must buffer those packets until the sequence is complete.

We suggest you follow this approach:

- Since the circular buffer will not allow you to write data in arbitrary locations (and
  only after the last byte of data in the buffer), you should store any out-of-order
  segments in a new list in the ``tcp_data_t`` struct. This list should be sorted by
  increasing sequence number.
- Whenever a new segment arrives, check the head of the out-of-order list to see
  whether there are any contiguous segments. For example, if you receive a segment
  with bytes 100-199, and the head of the list contains a segment with bytes
  200-299, that means the segment in the out-of-order list can now be processed.
- When this happens, we suggest that you simply remove the packet from the out-of-order
  list and add it to the pending packets queue. This will result in a ``PACKET_ARRIVAL``
  event and the out-of-order segment will be processed as usual by your packet arrival
  handler.
