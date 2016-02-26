.. _chirouter-testing:

Testing your Implementation
===========================

chirouter currently does not have automated tests, and all testing is done manually
from the mininet command-line interface. However, we provide a suggested order of
implementation that will allow you to verify that certain components of the router
are working correctly before moving on to other components.


Responding to ARP requests
--------------------------

Your very first task will be to respond to ARP requests. Otherwise, the other
devices on the network will be unable to send you IP datagrams.

To test whether you are generating correct ARP replies, you can run the following
from mininet::

   mininet> client1 ping -c 4 10.0.0.1
   
At this point, ping will not work (since you haven't implemented ICMP yet), but this
will make ``client1`` send an ARP request for 10.0.0.1. If you generate a correct ARP
reply, the reply will be stored in client1's ARP cache. You can see the state of this
cache by running ``arp -n`` in ``client1``. If your ARP reply was successful, you
will see and entry for ``10.0.0.1``::

   mininet> client1 arp -n
   Address                  HWtype  HWaddress           Flags Mask            Iface
   10.0.0.1                 ether   e2:37:3d:e5:c5:29   C                     client1-eth0

Note: ``client1``'s ARP cache is completely distinct from the one you're implementing. ``client1``
represents a computer on the network, and is completely simulated by mininet. You are implementing
the router, which has its own ARP cache (and which you cannot query or see from the mininet
CLI).
    
Responding to ICMP requests directed to the router
--------------------------------------------------

Next, implement the functionality described in :ref:`chirouter-assignment-icmp-basic`.
Remember that you don't have to send out ARP requests yet; when you receive a message
that triggers one of the ICMP responses described in that section of the assignment,
you can simply use the source Ethernet address as the destination address of the reply.

To test whether you're responding to Echo Replies correctly, just ping the router like
this::

   mininet> client1 ping -c 4 10.0.0.1
   PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
   84 bytes from 10.0.0.1: icmp_seq=1 ttl=255 time=17.5 ms
   84 bytes from 10.0.0.1: icmp_seq=2 ttl=255 time=34.5 ms
   84 bytes from 10.0.0.1: icmp_seq=3 ttl=255 time=51.4 ms
   84 bytes from 10.0.0.1: icmp_seq=4 ttl=255 time=18.8 ms
   
   --- 10.0.0.1 ping statistics ---
   4 packets transmitted, 4 received, 0% packet loss, time 3004ms
   rtt min/avg/max/mdev = 17.565/30.609/51.498/13.782 ms

To test whether you're generating ICMP Host Unreachable messages correctly, ping one
of the router's *other* IP addresses::

   mininet> client1 ping -c 4 192.168.1.1
   PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
   From 10.0.0.1 icmp_seq=1 Destination Host Unreachable
   From 10.0.0.1 icmp_seq=2 Destination Host Unreachable
   From 10.0.0.1 icmp_seq=3 Destination Host Unreachable
   From 10.0.0.1 icmp_seq=4 Destination Host Unreachable
   
   --- 192.168.1.1 ping statistics ---
   4 packets transmitted, 0 received, +4 errors, 100% packet loss, time 3005ms

To test whether you're generating ICMP Port Unreachable messages correctly, try
tracerouting the router::

   mininet> client1 traceroute 10.0.0.1
   traceroute to 10.0.0.1 (10.0.0.1), 30 hops max, 60 byte packets
    1  10.0.0.1 (10.0.0.1)  17.487 ms  17.826 ms  17.825 ms

Traceroute actually uses UDP packets where the IP datagram has increasingly larger TTLs.
This means that intermediate hops will return a Time Limit Exceeded response, and the
destination host will return a Port Unreachable when the IP datagram has the TTL
set to the right number of hops
