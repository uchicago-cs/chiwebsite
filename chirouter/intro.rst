Introduction
============

In this project you will be implementing a simple IP router capable of routing
IPv4 datagrams between multiple networks. This router will have a static routing
table, so you will not have to deal with implementing a routing protocol like
RIP or OSPF; instead, the project will focus on the routing of IP datagrams. While,
at a high level, this just involves receiving IP datagrams and figuring out
what interface they should be sent on, this requires building additional
functionality before you can actually start routing IP datagrams:

* Your code must process the raw Ethernet frames that arrive through the router's
  interfaces.
* Because you will be working at the Ethenet level, you will need to use ARP to map
  Ethernet addresses to IP addresses.  
* Your router will need to support a small subset of the ICMP protocol so
  you can use tools like ping and traceroute, and to notify hosts of certain errors
  (e.g., if the router is given an IP datagram it cannot forward).

The chirouter documentation is divided into the following sections:

* :ref:`chirouter-installing`: Instructions on how to install, build, and run
  chirouter.
* :ref:`chirouter-implementing`: A guide to implementing chirouter.
* :ref:`chirouter-assignment`: The work you must complete in this assignment.
* :ref:`chitcp-testing`: Suggestions and strategies for testing your
  implementation.
   
Acknowledgements
----------------

 This project is based on the `Simple Router assignment <https://github.com/mininet/mininet/wiki/Simple-Router>`_ 
 included in the Mininet project which, in turn, is based on a 
 `programming assignment developed at Stanford <http://www.scs.stanford.edu/09au-cs144/lab/router.html>`_.
 
 While most of the code, as well as the project specification, for chirouter has been written from scratch, some
 of the original Stanford code is still present in some places and, whenever
 possible, we have tried to provide the exact attribution for such code.
 Any omissions are not intentional and will be gladly corrected if
 you contact us at borja@cs.uchicago.edu.
 