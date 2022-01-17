Introduction
============

In this project you will be implementing the Transmission Control Protocol, as
specified in `[RFC793] <https://datatracker.ietf.org/doc/html/rfc793>`__. However, instead
of implementing it inside the operating system itself, you will be implementing
it inside a system called chiTCP. This system allows you to write socket-based
applications that rely on your TCP implementation instead of the one included
in your operating system. To do this, chiTCP provides an alternate socket
library, chisocket, that provides the same functions as the standard socket
library (``connect``, ``send``, ``recv``, etc.). Although the chisocket
functions have the same expected behaviour as the standard socket functions,
they do not implement the entire functionality provided by standard sockets
(e.g., non-blocking sockets are not supported).

In chiTCP, the socket layer and all the messy details of how TCP interacts with
the other layers of the protocol stack (including how packets are handed down
to the network layer, and how data is passed up to the application layer) are
already implemented for you. In this project, you will focus on implementing
the TCP protocol itself.

The chiTCP documentation is divided into the following sections:

* :ref:`chitcp-architecture`: Provides an overview of chiTCP's internal
  architecture.
* :ref:`chitcp-installing`: Instructions on how to install, build, and run
  chiTCP.
* :ref:`chitcp-implementing`: A guide to implementing chiTCP.
* :ref:`chitcp-assignment1` and :ref:`chitcp-assignment2`: The chiTCP
  programming assignments. Please note that your instructor may provide
  additional instructions on how to do these assignments.
* :ref:`chitcp-testing`: Suggestions and strategies for testing your
  implementation.
   
