.. _chirouter-installing:

Installing, Building, and Running chirouter
===========================================

The source code for chirouter can be found in the following GitHub repository:

    https://github.com/uchicago-cs/chirouter

To work on the assignments, all you need to do is clone this repository. However,
please note that your instructor may give you more specific instructions on how
to get the chirouter code.

Software Requirements
---------------------

The chirouter code itself has no special software requirements beyond a standard C compiler and the
standard C library. However, running chirouter requires using `mininet <http://mininet.org/>`_ (2.2.1 or higher), a 
network emulator that requires root access on a Linux machine.
If you do not have root access on your
personal computer, we recommend running mininet inside a virtual machine (the mininet website actually
provides some ready-to-use virtual machines).

chirouter also requires `OpenFlow <https://openflow.stanford.edu/>`_'s `POX <https://openflow.stanford.edu/display/ONL/POX+Wiki>`_,
but this is already included in the chirouter code.


Building
--------

Once you have the chirouter code, you can build it simply by running Make::

   make

This will generate an executable called ``chirouter`` that accepts the following
parameters:

* ``-p PORT``: [Optional] Port that chirouter will listen on (mininet and POX will use this port
  to send the router its configuration information). Defaults to 23300.
* ``-c FILE``: [Optional] When specified, produces a capture file (in PCAPNG format) with all
  the Ethernet frames sent/received by the routers. This file can be opened in Wireshark for analysis.
* ``-v``, ``-vv``, or ``-vvv``: To control the level of logging. This is described in 
  more detail in :ref:`chirouter-implementing`


Running
-------

To run chirouter, you must first run mininet and the POX controller, both of which are in charge
of simulating the network where your router is located. Running mininet requires root access, but
running the chirouter executable *does not*. So, there are two ways of running chirouter:

Running chirouter and mininet on a machine with root access
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have root access on the machine you are working on, you should start two terminals
and, on the first one, run chirouter::

   ./chirouter -vv

Note: The ``-vv`` parameter is not ordinarily necessary, but we will use it to verify that
chirouter and mininet are running correctly.

You should see the following::

   [2018-02-09 10:41:13]   INFO Waiting for connection from controller...
   
In a separate terminal, run mininet and POX like this::

   sudo ./run-mininet topologies/basic.json
   
``sudo`` will ask you to enter your password; once you do so, you should see the following output::

   *** Creating network
   *** Adding controller
   *** Adding hosts:
   client1 client2 server1 server2 
   *** Adding switches:
   r1 s1001 s1002 s1003 
   *** Adding links:
   (client1, s1003) (client2, s1003) (r1, s1001) (r1, s1002) (r1, s1003) (server1, s1001) (server2, s1002) 
   *** Configuring hosts
   client1 client2 server1 server2 
   *** Starting controller
   c0 
   *** Starting 4 switches
   r1 s1001 s1002 s1003 ...
   *** Starting CLI:
   mininet> 

Note: You may notice that there is a separate ``run-pox`` script. You do not need to run this script!
POX is launched automatically by mininet, so you only need to run the ``run-mininet`` script. 
There are some cases where it does make sense to launch
POX and mininet separately (and we describe those below)

Now, the terminal where you ran ``chirouter`` should show something like this::

   [2018-02-09 10:42:57]   INFO Controller connected from 127.0.0.1:58398
   [2018-02-09 10:42:58]   INFO Received 1 routers
   [2018-02-09 10:42:58]   INFO --------------------------------------------------------------------------------
   [2018-02-09 10:42:58]   INFO ROUTER r1
   [2018-02-09 10:42:58]   INFO 
   [2018-02-09 10:42:58]   INFO eth1 42:7C:1C:87:EE:5B 192.168.1.1
   [2018-02-09 10:42:58]   INFO eth2 82:4B:72:73:F7:5F 172.16.0.1
   [2018-02-09 10:42:58]   INFO eth3 0A:4B:3F:1B:E3:ED 10.0.0.1
   [2018-02-09 10:42:58]   INFO 
   [2018-02-09 10:42:58]   INFO Destination     Gateway         Mask            Iface           
   [2018-02-09 10:42:58]   INFO 192.168.0.0     0.0.0.0         255.255.0.0     eth1            
   [2018-02-09 10:42:58]   INFO 172.16.0.0      0.0.0.0         255.255.240.0   eth2            
   [2018-02-09 10:42:58]   INFO 10.0.0.0        0.0.0.0         255.0.0.0       eth3            
   [2018-02-09 10:42:58]   INFO --------------------------------------------------------------------------------

Note: The MAC addresses will likely be different. Everything else should be the same.

This means that chirouter has correctly received the network configuration from mininet.

Go back to the mininet terminal, which should show a command prompt like this::
   
   mininet> 
   
To verify that mininet is running correctly, you can run the following from the mininet prompt::

   mininet> client1 ping -c 4 client1
   PING 10.0.100.1 (10.0.100.1) 56(84) bytes of data.
   64 bytes from 10.0.100.1: icmp_seq=1 ttl=64 time=0.018 ms
   64 bytes from 10.0.100.1: icmp_seq=2 ttl=64 time=0.014 ms
   64 bytes from 10.0.100.1: icmp_seq=3 ttl=64 time=0.022 ms
   64 bytes from 10.0.100.1: icmp_seq=4 ttl=64 time=0.023 ms
   
   --- 10.0.100.1 ping statistics ---
   4 packets transmitted, 4 received, 0% packet loss, time 2999ms
   rtt min/avg/max/mdev = 0.014/0.019/0.023/0.004 ms

The above command just instructs ``client1`` to ping itself. Since your router isn't involved in delivering the
ICMP messages, this will run fine even if you haven't implemented the router yet. On the other hand, the following
command instructs ``client1`` to ping ``10.0.0.1`` (one of the router's interfaces). Since you have
not yet implemented ICMP in your router, it will not reply to the pings::

   mininet> client1 ping -c 4 10.0.0.1
   PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
   From 10.0.100.1 icmp_seq=1 Destination Host Unreachable
   From 10.0.100.1 icmp_seq=2 Destination Host Unreachable
   From 10.0.100.1 icmp_seq=3 Destination Host Unreachable
   From 10.0.100.1 icmp_seq=4 Destination Host Unreachable
   
   --- 10.0.0.1 ping statistics ---
   4 packets transmitted, 0 received, +4 errors, 100% packet loss, time 3014ms

However, if you look at the chirouter logs, you should see that it *is* receiving the ARP requests from ``client1``::

   [2018-02-09 10:48:39]  DEBUG Received Ethernet frame on interface eth3
   [2018-02-09 10:48:39]  DEBUG    ######################################################################
   [2018-02-09 10:48:39]  DEBUG <  Src: AA:60:D3:A1:F7:E8
   [2018-02-09 10:48:39]  DEBUG <  Dst: FF:FF:FF:FF:FF:FF
   [2018-02-09 10:48:39]  DEBUG <  Ethertype: 0806 (ARP)
   [2018-02-09 10:48:39]  DEBUG <  Payload (28 bytes):
   [2018-02-09 10:48:39]  DEBUG   0000  00 01 08 00 06 04 00 01 aa 60 d3 a1 f7 e8 0a 00  .........`......
   [2018-02-09 10:48:39]  DEBUG   0010  64 01 00 00 00 00 00 00 0a 00 00 01              d...........
   [2018-02-09 10:48:39]  DEBUG    ######################################################################

As you develop your router, please note that it is important that you start chirouter and mininet in
the same order: chirouter first, followed by mininet.


Running chirouter and mininet on separate machines
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Since mininet requires root access, it may sometimes be more convenient to run chirouter on your usual
development machine (e.g., your laptop), and mininet on a machine with root access. In particular,
it should be easy to run mininet inside a virtual machine running on the same machine where
you are doing your chirouter development.

To do this, you should clone your repository on the (non-root) machine, and run chirouter as follows::

   ./chirouter -vv -p PORT
   
Where ``PORT`` is the TCP port on which chirouter will listen for connections from mininet. If you
omit this parameter, port 23300 will be used by default.   
   
Next, on the root machine, it is enough to clone the upstream chirouter repository. In fact, none of your own
code will run on the root machine; only the mininet/POX code (which you do not need to modify in any way)
will run there.   
   
From the root machine, run mininet as follows::

   sudo ./run-mininet topologies/basic.json --chirouter HOST:PORT
   
Where ``HOST`` is the hostname or IP address of the machine running chirouter. If you are running mininet
inside a virtual machine, there will typically be a special IP address to connect to the VM's host machine
(which is where you're running chirouter). ``PORT`` is the port specified when running ``chirouter`` (or
23300 if you did not specify a ``-p`` parameter when running ``chirouter``)

You should now observe the same outputs as described earlier.


Running mininet and POX separately
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It can sometimes be useful, for debugging purposes, to run mininet and POX separately (in general, 
you should not do this unless your instructor asks you for the output of POX). To do so, you must run
the following commands in separate terminals, and in this order::

   ./chirouter -vv
   
::

   ./run-pox topologies/basic.json
   
::

   sudo ./run-mininet topologies/basic.json --pox 127.0.0.1:6633
 


