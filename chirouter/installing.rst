.. _chirouter-installing:

Installing, Building, and Running chirouter
===========================================

The source code for chiTCP can be found in the following GitHub repository:

    https://github.com/uchicago-cs/chirouter

To work on the assignments, all you need to do is clone this repository. However,
please note that your instructor may give you more specific instructions on how
to get the chirouter code.

Software Requirements
---------------------

The chirouter code itself has no special software requirements beyond a standard C compiler and the
standard C library. However, running chirouter requires using `mininet <http://mininet.org/>`_, a 
network emulator that requires root access on a Linux machine (you will need version 2.2.1 or higher).
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

* ``-r RTABLE``: The routing table for the router
* ``-s POX_HOST``: The host running the POX controller (default: localhost)
* ``-p POX_PORT``: The port the POX controller is listening on
* ``-v``, ``-vv``, or ``-vvv``: To control the level of logging. This is described in 
  more detail in :ref:`chirouter-implementing`


Running
-------

To run chirouter, you must first run mininet and the POX controller, both of which are in charge
of simulating the network where your router is located. Running mininet requires root access, but
running the chirouter executable *does not*. 

If you are using a virtual machine, this means that you can use the virtual machine exclusively to
run mininet and POX, and then develop and run chirouter in your usual environment. However, you will
need to clone the chirouter repository on the virtual machine to have access to the mininet and POX
commands there.

First, start POX like this::

   ./run_pox.sh topologies/basic/
   
You should see something like this::

   POX 0.2.0 (carp) / Copyright 2011-2013 James McCauley, et al.
   [2016-02-26 10:40:06,017] DEBUG    core POX 0.2.0 (carp) going up...
   [2016-02-26 10:40:06,019] DEBUG    core Running on CPython (2.7.10/Oct 14 2015 16:09:02)
   [2016-02-26 10:40:06,021] DEBUG    core Platform is Linux-4.2.0-23-generic-x86_64-with-Ubuntu-15.10-wily
   [2016-02-26 10:40:06,021] INFO     core POX 0.2.0 (carp) is up.
   [2016-02-26 10:40:06,032] DEBUG    of_01 Listening on 0.0.0.0:6633

Next, on a separate terminal, run mininet like this::

   ./run_mininet.sh topologies/basic/
   
Note that the ``run_mininet.sh`` script will run a mininet command with ``sudo``, so you may be asked to 
enter your password. If the command runs successfully, you should see a fair amount of output starting with this::

   *** Creating network
   *** Creating network
   *** Adding controller
   *** Adding hosts:
   client1 client2 server1 server2 
   *** Adding switches:
   router9999 switch12 
   
And ending with this::
   
   *** Starting CLI:
   mininet> 

This is a command prompt where you will be able to run standard network commands. Each command
must be prefaced with the name of the machine you want to run the command on. For example, this command
runs ``ping`` on ``client1`` (and specifically pings ``server1``)::

   client1 ping server1
   
Once you start mininet, you should verify that it has connected to the POX controller correctly. On the
terminal that is running POX, you should see log messages like this::

   [2016-02-26 10:47:42,651] INFO     of_01 [None 1] closed
   [2016-02-26 10:47:42,786] INFO     of_01 [00-00-00-00-27-0f 2] connected
   [2016-02-26 10:47:42,787] DEBUG    pox_controller Controlling [00-00-00-00-27-0f 2] (dpid: 9999)
   [2016-02-26 10:47:42,787] INFO     pox_controller Creating new Controller
   [2016-02-26 10:47:42,787] INFO     pox_controller Adding interface eth3 with IP 10.0.0.1
   [2016-02-26 10:47:42,787] INFO     pox_controller Adding interface eth2 with IP 172.16.0.1
   [2016-02-26 10:47:42,787] INFO     pox_controller Adding interface eth1 with IP 192.168.1.1
   [2016-02-26 10:47:42,787] DEBUG    pox_controller Made new SRController on port 9999
   [2016-02-26 10:47:42,787] DEBUG    pox_controller Starting connections
   [2016-02-26 10:47:42,789] INFO     of_01 [00-00-00-00-00-0c 3] connected
   [2016-02-26 10:47:42,789] DEBUG    pox_controller Controlling [00-00-00-00-00-0c 3] (dpid: 12)
   [2016-02-26 10:47:42,789] DEBUG    pox_controller Made new SwitchController
 
Some of the messages may have slightly different values, but the "Adding interface" messages should
be as above (although they could appear in different order).
   
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
ICMP messages, this will run fine even if you haven't implemented the router yet. On the other hand, the following command
will result in no pings being delivered, because ``client1`` and ``server1`` are on different networks::

   mininet> client1 ping -c 4 server1
   PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
   From 10.0.100.1 icmp_seq=1 Destination Host Unreachable
   From 10.0.100.1 icmp_seq=2 Destination Host Unreachable
   From 10.0.100.1 icmp_seq=3 Destination Host Unreachable
   From 10.0.100.1 icmp_seq=4 Destination Host Unreachable
   
   --- 192.168.1.2 ping statistics ---
   4 packets transmitted, 0 received, +4 errors, 100% packet loss, time 3014ms


