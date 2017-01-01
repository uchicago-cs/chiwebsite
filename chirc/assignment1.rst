.. _chirc-assignment1:

Assignment 1: Basic Message Processing
======================================

This first assignment is meant as a warm-up exercise to get reacquainted
with socket programming. You must implement an IRC server that
implements the ``NICK`` and ``USER`` messages only well enough to
perform a *single* user registration as shown in :ref:`chirc-irc-examples`.
Take into account that a barely minimal server that meets these
requirements, and passes most of the automated tests for this assignment, can be
written in roughly 50 lines of C code (in fact, we will *give you* those
50 lines of code). However, although this kludgy solution will get you a
near perfect score on the tests, it will earn you a zero on the design grade.

So, you should start implementing your solution with the requirements of
the rest of the project in mind. More specifically, your solution to
this assignment should meet the following requirements:

-  (A) You must send the ``RPL_WELCOME`` *only* after the
   ``NICK`` and ``USER`` messages have been received.

-  (B) You must take into account that you may get more or less
   than one full message when you read from a socket. You may not solve
   this problem by reading one character at a time from the socket.

-  (C) Your solution must parse the nick and username from the
   ``NICK`` and ``USER`` messages, and compose the correct
   ``RPL_WELCOME`` reply.

Although not required for this assignment, you should take into account
that the remaining two parts of the project will involve adding support
for additional messages and replies. Any time you spend writing a message parser and
constructor (that works with more than just ``NICK`` and ``USER``) will
be time well spent. However, if your solution to this assignment takes some
shortcuts by assuming that you will only be dealing with the ``NICK``
and ``USER`` messages and the ``RPL_WELCOME`` reply, you will not be
penalized for it.

Your server must be implemented in C, and must use sockets. There should
be no need for you to use pthreads at this point.

