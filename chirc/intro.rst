Introduction
============

In this project, you will implement a simple Internet Relay Chat (IRC)
server called **chirc**. IRC is one of the earliest network protocols 
for text messaging and multi-participant chatting. It remains a popular
standard and still sees heavy use in certain communities, specially the
open source software community.

Your implementation must be compliant enough
with the official IRC specification for
other IRC clients (not programmed by you) to work with your server. Although
we will provide some scaffolding, most tasks will require you to consult
the official IRC specification, or to experiment with existing IRC servers.
Thus, this project will allow you to develop not just your network programming skills,
but also your ability to read and interpret a real network protocol.

This project is divided into three parts. The first part is meant as a
relatively short warmup exercise; the second part mostly revolves
around supporting multiple clients and messaging between individual users;
the third part mostly revolves around implementing IRC "channels" (the IRC's
equivalent of a "chat group" or a "chat room").

The chirc documentation is divided into the following sections:

* :ref:`chirc-irc` and :ref:`chirc-irc-examples` provide an overview of 
  the IRC protocol and provide several examples of valid IRC communications.
* :ref:`chirc-build` describes how to get the chirc code and how to build and run it.
* :ref:`chirc-assignment1`, :ref:`chirc-assignment2`, and :ref:`chirc-assignment3`,
  describe the three parts of this project.
* :ref:`chirc-testing` provides suggestions and strategies for testing your implementation.
