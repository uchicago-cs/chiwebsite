Introduction
============

In this project, you will implement a simple Internet Relay Chat (IRC)
server called **chirc**. IRC is one of the earliest network protocols
for text messaging and multi-participant chatting. It is still in use
in certain communities, especially the open source software community.

Your implementation must be compliant enough
with the official IRC specification for
other IRC clients (not programmed by you) to work with your server. Although
we will provide some scaffolding, most tasks will require you to consult
the official IRC specification, or to experiment with existing IRC servers.
Thus, this project will allow you to develop not just your network programming skills,
but also your ability to read and interpret a real network protocol.

This project is divided into four parts. The first part (Assignment 1) is
meant as a relatively short warmup exercise; the second part (Assignment 2)
mostly revolves around supporting multiple clients and messaging between
individual users; the third part (Assignment 3) mostly revolves around
implementing IRC "channels" (the IRC's equivalent of a "chat group" or a
"chat room") and modes; the fourth part (Assignment 5) revolves around
supporting IRC networks composed of multiple servers. Assignment 4 is an
abridged version of Assignments 2 and 3, which can be done instead of those
two assignments.

The chirc documentation is divided into the following sections:

* :ref:`chirc-irc` and :ref:`chirc-irc-examples` provide an overview of
  the IRC protocol and provide several examples of valid IRC communications.
* :ref:`chirc-build` describes how to get the chirc code and how to build and run it.
* :ref:`chirc-assignment1`, :ref:`chirc-assignment2`, :ref:`chirc-assignment3`,
  :ref:`chirc-assignment4`, and :ref:`chirc-assignment5` describe the four
  parts of this project.
* :ref:`chirc-testing` provides suggestions and strategies for testing your implementation.
