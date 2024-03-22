.. _chirc-assignment1:

Assignment 1: Basic Message Processing
======================================

This first assignment is meant as a warm-up exercise to get reacquainted
with socket programming. You must implement an IRC server that
implements the ``NICK`` and ``USER`` messages only well enough to
perform a *single* user registration as shown in :ref:`chirc-irc-examples`.

More specifically, your solution to
this assignment should meet the following requirements:

-  (A) You must send the ``RPL_WELCOME`` *only* after the
   ``NICK`` and ``USER`` messages have been received.

-  (B) You must take into account that you may get more or less
   than one full message when you read from a socket. You may not solve
   this problem by reading one character at a time from the socket.

-  (C) Your solution must parse the nick and username from the
   ``NICK`` and ``USER`` messages, and compose the correct
   ``RPL_WELCOME`` reply. You must use the provided ``message.c``
   module for this.

Although not required for this assignment, you should take into account
that subsequent assignments will involve adding support
for additional messages and replies. So, while it is possible to implement
your solution entirely inside the ``chirc_run`` function in ``main.c``,
you should start looking at the ``handlers.c`` module, which provides
a more robust mechanism for dispatching messages to handler functions
that will process them.

That said, if your solution to this assignment takes some
shortcuts by assuming that you will only be dealing with the ``NICK``
and ``USER`` messages and the ``RPL_WELCOME`` reply, you will not be
penalized for it.

Your server must be implemented in C, and must use sockets. There should
be no need for you to use pthreads at this point.

