======
chiTCP
======

chiTCP is a programming assignment where students have to implement the TCP
protocol. It provides a framework for students to bypass the operating system’s
TCP stack and, instead, use a sandboxed and testable TCP stack that runs in
userspace (instead of kernelspace). All the details of how TCP interacts with
the other layers of the protocol stack (including how packets are handed down
to the network layer, and how data is passed up to the application layer) are
already implemented for the students, who can then focus on implementing the
TCP protocol itself. Furthermore, chiTCP also allows students to write
socket-based network applications on top of their TCP implementation (by using
a "chisocket" library instead of the standard socket library). If two students
write standard-compliant versions of TCP, their applications will be able to
communicate over a real network.

.. toctree::
   :maxdepth: 2

   intro.rst
   architecture.rst
   installing.rst
   implementing.rst
   assignment1.rst
   assignment2.rst
   testing.rst
   
