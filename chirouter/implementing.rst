.. _chirouter-implementing:

Implementation Guide
====================

You are provided with a fair amount of scaffolding code, some of which
you will need to use or modify to implement your router. This page
provides an overview of the files that you will need to modify or
be familiar with. Most of the documentation on individual functions
can be found in the header files themselves.


chirouter.h
-----------

This header file defines the main data structures of an individual router. All these
data structures are accessible through the *router context* struct (``chirouter_ctx_t``)
that is passed to most functions.

Our code takes care of creating and populating this struct with all the 
information relevant to each router:

* An array of ``chirouter_interface_t`` structs, each representing an Ethernet
  interface in the router.
* An array of ``chirouter_rtable_entry_t`` structs, each representing an entry
  in the routing table. Each entry in the routing table, in turn, contains
  the destination network (specified by an IPv4 address and a subnet mask), the
  gateway for that entry, and the Ethernet interface for that entry (a pointer
  to a ``chirouter_interface_t`` struct). 
* An ARP cache, represented as an array of ``chirouter_arpcache_entry_t`` structs.
* A list of pending ARP requests, representing ARP requests that have been sent
  but for which the router has not received a reply yet. This is explained in more
  detail in :ref:`chirouter-assignment`. 
* A mutex that must be locked any time the ARP cache or the list of pending ARP requests
  is accessed.
  
This header file also defines an ``ethernet_frame_t`` struct representing an *inbound*
Ethernet frame. This struct contains not just the frame itself, but also a pointer to the
``chirouter_interface_t`` struct corresponding to the Ethernet interface on which the
frame arrived.

You should not modify this header file in any way.

router.c
--------

Most of your work will take place in this file. In particular, you must implement the
``chirouter_process_ethernet_frame`` function. This function will get called every 
time an Ethernet frame is received by
a router. 

Take into account that chirouter can manage multiple routers at once, 
but does so in a single thread. i.e., it is guaranteed that this function 
is always called sequentially, and that there will not be concurrent calls to this
function. If two routers receive Ethernet frames "at the same time",
they will be ordered arbitrarily and processed sequentially, not
concurrently (and with each call receiving a different router context)

Your implementation of the ``chirouter_process_ethernet_frame`` function must
process the frame meeting the requirements described in :ref:`chirouter-assignment`.
You are allowed, and encouraged, to use helper functions to implement ``chirouter_process_ethernet_frame``.
For example, it would make sense to write separate functions to handle ARP messages,
ICMP messages directed to the router, and IP datagrams.


arp.c / arp.h
-------------

Part of your work will take place in this file. In particular, you must implement the
``chirouter_arp_process_pending_req`` function. Besides the router's main thread (which
is in charge of calling ``chirouter_process_ethernet_frame`` when an Ethernet frame
arrives), the router has an additional thread, *the ARP thread*, that runs function ``chirouter_arp_process``.
This thread will wake up every second to purge stale entries in the ARP cache 
(entries that are more than 15 seconds old) and to traverse the list of pending ARP requests. 

For each pending request in the list, it will call ``chirouter_arp_process_pending_req``,
which must either re-send the pending ARP request or cancel the request and send 
ICMP Host Unreachable messages in reply to all the withheld frames (this is
described in more detail in :ref:`chirouter-assignment`.).

Because the main thread and the ARP thread may both need to access the ARP cache or the
list of pending ARP requests at the same time, you must *always* lock the ``lock_arp`` mutex
(in the router context) before accessing either the ARP cache or the list of pending ARP
requests (even if you are just reading them).

You must not modify any code in this file other than ``chirouter_arp_process_pending_req``.
However, this file does provide several functions to access and/or manipulate the
ARP cache and list of pending ARP requests, which you can use in your implementation.
Take into account that these functions assume that the ``lock_arp`` mutex has already been
locked before the functions are called.
 
 
The ``chirouter_send_frame`` function
-------------------------------------

When an Ethernet frame arrives and is processed in ``chirouter_process_ethernet_frame`` you will,
in many cases, have to *send* an Ethernet frame through one of the router's interfaces. 
This is done using the ``chirouter_send_frame`` function, defined in the ``chirouter.h`` header file. 


ethernet.h, arp.h, icmp.h, and ipv4.h
-------------------------------------

These header files (located in the ``src/router/protocols`` directory) provide structs that
allow easy access to the values contained in Ethernet, ARP, ICMP, and IPv4 headers.

Given an inbound Ethernet frame (an ``ethernet_frame_t`` struct), you can access the
different headers like this::

   /* Accessing the Ethernet header */
    ethhdr_t* hdr = (ethhdr_t*) frame->raw;
    
   /* Accessing the IP header */
   iphdr_t* ip_hdr = (iphdr_t*) (frame->raw + sizeof(ethhdr_t));
   
   /* Accessing an ARP message */
   arp_packet_t* arp = (arp_packet_t*) (frame->raw + sizeof(ethhdr_t));
   
   /* Accessing an ICMP message */
   icmp_packet_t* icmp = (icmp_packet_t*) (frame->raw + sizeof(ethhdr_t) + sizeof(iphdr_t));
   

utils.c / utils.h
-----------------

This module provides two useful functions: one to compute an IP or ICMP checksum, and one to
compare MAC addresses. If you need to add functions in your implementation that need to
be shared by ``router.c`` and ``arp.c``, you should add them to this module.


The logging functions
---------------------

chirouter prints out detailed information to standard output using a
series of logging functions declared in ``src/router/log.h``. We encourage you
to use these logging functions instead of using ``printf`` directly. More
specifically, you should use the printf-style ``chilog()`` function to print
messages:

.. code-block:: c

    chilog(DEBUG, "Received Ethernet frame with unsupported Ethertype: %i)", ntohs(hdr->type));

And the ``chilog_ethernet()``, ``chilog_arp()``, ``chilog_ip()``, and
``chilog_icmp()`` functions to dump the contents of an Ethernet header,
ARP message, IP header, or ICMP message. For example:

.. code-block:: c

    int reply_len = sizeof(ethhdr_t) + sizeof(iphdr_t) + ICMP_HDR_SIZE + payload_len;
    uint8_t reply[reply_len];
    memset(reply, 0, reply_len);

    ethhdr_t* reply_ether_hdr = (ethhdr_t*) reply;
    iphdr_t* reply_ip_hdr = (iphdr_t*) (reply + sizeof(ethhdr_t));
    icmp_packet_t* reply_icmp = (icmp_packet_t*) (reply + sizeof(ethhdr_t) + sizeof(iphdr_t));
    
    /* Set values in all the headers */

    chilog(DEBUG, "Sending ICMP packet");
    chilog_ip(DEBUG, reply_ip_hdr, LOG_OUTBOUND);
    chilog_icmp(DEBUG, reply_icmp, LOG_OUTBOUND);

The last parameter of these functions can be ``LOG_INBOUND`` or ``LOG_OUTBOUND``
to designate a message that is being received or sent, respectively (this
affects the formatting of the message in the log). ``LOG_NO_DIRECTION`` can also
be used to indicate that the message is neither inbound nor outbound.

In all the functions, the first parameter is used to specify the log level:

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
``chirouter``:

-  No ``-v`` argument: Print only ``CRITICAL`` and ``ERROR`` messages.

-  ``-v``: Also print ``WARNING`` and ``INFO`` messages.

-  ``-vv``: Also print ``DEBUG`` messages.

-  ``-vvv``: Also print ``TRACE`` messages.

We recommend running at the ``-vv`` level, which will print all the inbound
Ethernet frames. The ``-vvv`` contains much lower-level information that
the instructors may need to debug a specific issue, but which is typically
not relevant in most situations when implementing chirouter.
