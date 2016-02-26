.. _chirouter-assignment:

Assignment: Implementing an IP router
=====================================

This assignment is divided into three main tasks:

-  ICMP (35 points)
-  ARP (45 points)
-  IP forwarding (20 points)

You will be able to implement part of the ICMP support before implementing ARP.
However, you will need to implement ARP to complete your ICMP implementation. 
Basic IP forwarding will work once you have implemented ARP, but will 
require ICMP functionality to get full credit.

The :ref:`chirouter-testing` page provides a suggested implementation order
that will allow you to test individual parts of your router as you progress through
your implementation.


.. _chirouter-assignment-icmp-basic:

ICMP (Basic functionality)
--------------------------

ICMP is specified in `RFC 792 <https://tools.ietf.org/html/rfc792>`_. However, you
only need to support a small subset of ICMP. More specifically:

* If your router receives an IP datagram directed to one of its IP addresses,
  but that IP address is *not* the IP address of the interface on which the
  datagram was received, send an ICMP Host Unreachable message to the host
  that sent the IP datagram.
* If your router receives an ICMP Echo Request directed to one of its IP addresses, 
  you must send an ICMP Echo Reply to the host that sent the ICMP Echo Request.
* If your router receives a TCP/UDP packet directed to one of its IP addresses,
  you must send an ICMP Port Unreachable to the host that sent that TCP/UDP packet.

For the above, you can assume that the source Ethernet address of the frame that
triggered one of the above responses can be used as the destination Ethernet address
when sending the ICMP message. i.e., you do not need to use ARP at this point.

ARP (Basic functionality)
-------------------------
