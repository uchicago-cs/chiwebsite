.. _chirouter-assignment:

Assignment: Implementing an IP router
=====================================

This assignment is divided into three main tasks:

-  ICMP (35 points)
-  ARP (45 points)
-  IP forwarding (20 points)

These three tasks cannot be done entirely in sequence, since there are some dependencies
between them. The :ref:`chirouter-testing` page provides a suggested implementation order
that will allow you to test individual parts of your router as you progress through
your implementation. This page, on the other hand, specifies the full functionality
you must implement.


.. _chirouter-assignment-icmp:

ICMP
----

ICMP is specified in `RFC 792 <https://tools.ietf.org/html/rfc792>`_. However, you
only need to support a small subset of ICMP:

* Echo Replies (ICMP Type 0) and Requests (ICMP Type 8)
* Destination Unreachable (ICMP Type 3):

  * Network Unreachable (Code 0)
  * Host Unreachabe (Code 1)
  * Port Unreachable (Code 3)
  
* Time Exceeded (ICMP Type 11)

When your router receives certain IP datagrams directed to one of its IP
addresses, you will need to send an ICMP reply:

* If your router receives an IP datagram directed to one of its IP addresses,
  but that IP address is *not* the IP address of the interface on which the
  datagram was received, send an ICMP Host Unreachable message to the host
  that sent the IP datagram.
* If your router receives an IP datagram directed to one of its IP addresses,
  and that IP datagram's TTL is 1, you must send a Time Exceeded message to
  the host that sent the IP datagram (Note: Once you implement IP forwarding,
  this behaviour will change slightly)
* If your router receives an ICMP Echo Request directed to one of its IP addresses, 
  you must send an ICMP Echo Reply to the host that sent the ICMP Echo Request.
* If your router receives a TCP/UDP packet directed to one of its IP addresses,
  you must send an ICMP Port Unreachable to the host that sent that TCP/UDP packet.

For the above, you can assume that the source Ethernet address of the frame that
triggered one of the above responses can be used as the destination Ethernet address
when sending the ICMP message. i.e., you do not need to use ARP at this point.

You will also implement the following ICMP functionality, which is tied to ARP and
IP forwarding and described in more detail in the sections below:

* If your router receives an IP datagram that it cannot forward according to
  its routing table, you must send an ICMP Network Unreachable reply.
* If your router receives an IP datagram that it *can* forward, but no host
  on the target network replies to an ARP request, you must send an
  ICMP Host Unreachable reply. 


ARP
---

ARP is specified in `RFC 826 <https://tools.ietf.org/html/rfc826>`_. Your router
must be able to respond to ARP requests from other hosts, and will also need
to generate ARP requests before it can forward IP datagrams to other hosts.

Implementing ARP replies is straightforward: if your router receives an ARP request
on one of its interfaces, and that ARP request is for that interface's IP address,
you must send back an ARP reply to the host that sent the request.

Sending ARP requests is a bit more elaborate, because it is intertwined with IP
forwarding. When your router is given an IP datagram, and it determines that the
IP datagram can be forwarded to one of its interfaces, the router will need the
MAC address of the destination host. 

Your router has an ARP cache, and you must always check whether an entry already
exists for that IP address. If it does not, you will need to send
an ARP request for that MAC address.

However, after sending the ARP request, you *must not* actively wait for the reply.
Instead, you must create a pending ARP request (see :ref:`chirouter-implementing`)
and add it to the list of pending ARP requests. You must also add the IP datagram
to that pending request's list of withheld frames (if an ARP reply arrives, we want
those frames to be sent to their destination).

Take into account that, if you have already created a pending ARP request for a specific
IP address, and receive another datagram for that IP, then you must not create a new
pending request; instead, you will just get the existing pending request, and add the
datagram to the list of withheld frames.

If an ARP reply does arrive, you must add the IP/MAC mapping to the ARP cache. You
must also fetch the pending ARP request, and forward all withheld frames (since you
will now know what MAC address to send them to). You must also remove the pending
ARP request from the pending ARP request list. 

Regarding the ARP cache, take into account that entries in the ARP cache will time 
out after 15 seconds, but this is handled by our code; you are only responsible for 
adding entries to the cache. 

Of course, it is possible for a reply to never arrive. Our code provides an ARP thread
that will wake up every second and will call ``chirouter_arp_process_pending_req``
on each pending ARP request. In this function, you must re-send the pending ARP 
request, unless the request has already been sent five times, in which case you 
will send an ICMP Host Unreachable reply for each of the frames in the withheld frame list.


IP Forwarding
-------------

When your routers receive an IP datagram that is *not* directed to one of its IP addresses,
you must check whether the IP datagram can be forwarded. You must check the routing table
and see whether the destination IP address of the IP datagram matches any of the
networks in the routing table. In this project, we will assume that all the networks
have non-overlaping address ranges (e.g., it is not possible for the routing table
to contain 192.168.0.0/16 and 192.168.100.0/24; note that this is perfectly legitimate
in a router). This means that there will either be a single matching network, or none at all.

If there is no match in the routing table, then you must send an ICMP Network Unreachable
reply to the host that sent that IP datagram.

If there is a match, and you are able to obtain the MAC address for that IP address (see
ARP section above), then you must decrement the TTL of the IP datagram by one, recompute
the IP header checksum, and send the IP datagram on the appropriate interface. If the TTL
of the datagram is 1 (which means decrementing it by one will make the TTL equal to zero),
you must send an ICMP Time Exceeded reply.

However, take into account that you must only send the ICMP Time Exceeded reply if the IP
datagram can be forwarded and you have been able to obtain a MAC address for it. If not,
sending a Network Unreachable or Host Unreachable reply takes precedence. In other words,
you should not unconditionally return a Time Exceeded reply if you receive *any* IP
datagram with a TTL of 1.


