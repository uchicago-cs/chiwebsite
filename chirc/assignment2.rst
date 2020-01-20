.. _chirc-assignment2:

Assignment 2: Supporting Multiple Clients
=========================================

In this part of the project, your main goal will be to allow users to
send messages to each other. You will
also implement a couple extra messages that will make your server
compliant enough to test with existing IRC clients.

Since you will be supporting multiple users, you will now have to spawn
a new thread for each user that connects to your server. This, in turn,
may result in race conditions in your code. You must identify the shared
resources in your server, and make sure they are protected by adequate
synchronization primitives.

The messages you have to implement are presented in suggested order of
implementation. Nonetheless, once you’ve implemented Connection
Registration, the remaining messages are mostly independent of each
other.

Connection Registration
-----------------------

Implement connection registration, as described in `[RFC2812 §3.1] <http://tools.ietf.org/html/rfc2812#section-3.1>`__, 
with the following exceptions:

-  You must implement the ``NICK``, ``USER``, and ``QUIT`` messages. You
   must *not* implement the ``PASS``, ``SERVICE``, or ``SQUIT``
   messages. You do not need to implement the ``OPER`` and ``MODE``
   messages yet (you will implement them in the next assignment).

-  In the ``NICK`` message, you must implement the ``ERR_NONICKNAMEGIVEN``
   and ``ERR_NICKNAMEINUSE`` replies.

-  You can ignore the ``<mode>`` and ``<unused>`` parameters of the
   ``USER`` message.

-  In the ``USER`` message, you must implement the ``ERR_ALREADYREGISTRED``,
   and ``ERR_NEEDMOREPARAMS``. **Note**: You will need to support the
   ``ERR_NEEDMOREPARAMS`` reply in several other messages. It will pay
   off to write a function that validates the number of parameters in a message,
   and returns an ``ERR_NEEDMOREPARAMS`` reply if the number of parameters
   is insufficient.

-  After a connection has been registered, the ``RPL_WELCOME`` reply
   must be followed by the ``RPL_YOURHOST``, ``RPL_CREATED``,
   ``RPL_MYINFO`` replies (in that order). For the ``RPL_MYINFO`` reply,
   the user modes are ``ao`` and the channel modes are ``mtov``.

-  The ``ERROR`` message sent in reply to a ``QUIT`` must include this
   error message::

       Closing Link: HOSTNAME (MSG)

   Where ``HOSTNAME`` is the user’s hostname and `MSG`` is the ``<Quit Message>``
   parameter provided in the ``QUIT`` message. If none is provided, the
   default is ``Client Quit``

Take into account the following:

-  The ``NICK`` and ``USER`` messages can be received in any order, and
   a connection is not *fully* registered until both messages have been
   received (and neither contain any errors)

-  If you receive any message other than ``NICK`` or ``USER`` before the
   connection registration is complete, you must send a ``ERR_NOTREGISTERED``
   reply if that message contained a supported command (i.e., one of the
   commands we are asking you to implement in this project).
   Otherwise, you should just silently ignore that message. Take into account
   that, once registration is complete, this behavior will change (see
   ``ERR_UNKNOWNCOMMAND`` below)

-  The ``NICK`` command can also be used *after* the connection
   registration to change a user’s nick.

-  You can safely skip the ``QUIT`` command and revisit it later, as no
   other commands depend on it.

-  Most IRC servers send the replies corresponding to the ``MOTD`` and
   ``LUSER`` messages after the welcome messages are sent. Most of our
   tests expect this but, until you implement ``MOTD`` and ``LUSER``,
   you can get away with simply sending the following replies verbatim::

      :hostname 251 user1 :There are 1 users and 0 services on 1 servers
      :hostname 252 user1 0 :operator(s) online
      :hostname 253 user1 0 :unknown connection(s)
      :hostname 254 user1 0 :channels formed
      :hostname 255 user1 :I have 1 clients and 1 servers
      :hostname 422 user1 :MOTD File is missing

   This will be enough to pass the connection registration tests (they
   check that the correct replies are sent, but don’t actually check
   whether they contain accurate information).

``PRIVMSG`` and ``NOTICE``
--------------------------

Implement messaging between users, as described in `[RFC2812 §3.3] <http://tools.ietf.org/html/rfc2812#section-3.3>`__, with the
following exceptions:

-  The only supported ``<msgtarget>`` is nicknames.

-  You must implement the ``ERR_NORECIPIENT``, ``ERR_NOTEXTTOSEND``. and ``ERR_NOSUCHNICK`` replies.

Take into account the following:

-  If user ``user1`` sends a sequence of ``PRIVMSG`` messages to
   ``user2``, then ``user2`` *must* receive them in the same order that
   ``user1`` sent them.

-  If users ``user1`` and ``user2`` each send a single message to
   ``user3``, the messages are not expected to arrive in the same order
   that ``user1`` and ``user2`` sent them.

``PING`` and ``PONG``
---------------------

Implement the ``PING`` and ``PONG`` commands, as described in `[RFC2812 §3.7.2] <http://tools.ietf.org/html/rfc2812#section-3.7.2>`__ 
and `[RFC2812 §3.7.3] <http://tools.ietf.org/html/rfc2812#section-3.7.3>`__,
with the following exceptions:

-  You can ignore the parameters in ``PING``, and simply send the
   ``PONG`` response to the client that sent the ``PING`` message.

-  You must silently drop any ``PONG`` messages you receive (do *not*
   send a ``ERR_UNKNOWNCOMMAND`` reply)

Take into account the following:

-  Implementing ``PING`` and ``PONG`` is essential to testing your
   server with real IRC clients. IRC clients will sent ``PING`` messages
   periodically and, if they do not receive a ``PONG`` message back,
   they will close the connection.

``MOTD``
--------

Implement the ``MOTD`` command, as described in `[RFC2812 §3.4.1] <http://tools.ietf.org/html/rfc2812#section-3.4.1>`__, 
with the following exceptions:

-  You can ignore the ``<target>`` parameter.

Take into account the following:

-  Your server should read the “Message Of The Day” from a file called
   ``motd.txt`` in the directory from where you ran the server.

-  If the file does not exist, you must return a ``ERR_NOMOTD`` reply.

``LUSERS``
----------

Implement the ``LUSERS`` command, as described in `[RFC2812 §3.4.2] <http://tools.ietf.org/html/rfc2812#section-3.4.2>`__, 
with the following exceptions:

-  You can ignore the ``<mask>`` and ``<target>`` parameters.

-  You must return the replies in the following order:
   ``RPL_LUSERCLIENT``, ``RPL_LUSEROP``, ``RPL_LUSERUNKNOWN``,
   ``RPL_LUSERCHANNELS``, ``RPL_LUSERME``

-  You do not need to support the ``ERR_NOSUCHSERVER`` reply

Take into account the following:

-  You must send the replies even when they are reporting a zero value
   (i.e., ignore this from `[RFC2812 §5.1] <http://tools.ietf.org/html/rfc2812#section-5.1>`__: “When
   replying, a server MUST send back RPL\_LUSERCLIENT and RPL\_LUSERME.
   The other replies are only sent back if a non-zero count is found for
   them.”)

-  An “unknown connection” is any connected client for which we cannot yet 
   tell whether the connection corresponds to a user (or, starting in
   Assignment 5, another server). Once a connection receives either
   a ``NICK`` or a ``USER`` command, we can assume that it corresponds
   to a user connection.

-  The number of users in the ``RPL_LUSERCLIENT`` reply is the number of
   registered users (i.e., connections that have successfully sent both
   ``NICK`` and ``USER`` and have completed their registration).

-  The number of clients in the ``RPL_LUSERME`` reply is the total
   number of connections, *not* including unknown connections.

``WHOIS``
---------

Implement the ``WHOIS`` command, as described in `[RFC2812 §3.6.2] <http://tools.ietf.org/html/rfc2812#section-3.6.2>`__, with the
following exceptions:

-  The command must accept a single parameter: a nick (i.e., there is
   only a single ``<mask>``, and it must be a nick; ignore the
   ``<target>`` parameter)

-  Ordinarily, the ``WHOIS`` command can be used without parameters, so
   the RFC does not *not* require a ``ERR_NEEDMOREPARAMS`` reply in this case.
   However, since we do not support ``WHOIS`` without parameters, if you
   receive such a message you should silently ignore it (i.e., don't send any
   reply back at all)

-  You must only send back the following replies, in this order:
   ``RPL_WHOISUSER``, ``RPL_WHOISSERVER``, ``RPL_ENDOFWHOIS``.

-  You must supply a value for parameter ``<server info>`` in
   ``RPL_WHOISSERVER``, but we won’t be checking its contents.

-  You must support the ``ERR_NOSUCHNICK`` reply.

Take into account the following:

-  You will be implementing ``RPL_WHOISOPERATOR``,
   ``RPL_WHOISCHANNELS``, and ``RPL_AWAY`` in the next assignment.

``ERR_UNKNOWNCOMMAND``
----------------------

If, after registering correctly, your server receives any message not described here 
(or in the next assignment), you must return a ``ERR_UNKNOWNCOMMAND`` reply.


Robustness
----------

Your code must pass the "Robustness" suite of tests (see :ref:`chirc-testing` for instructions
on how to run the tests). These tests check that your code
does not crash in certain corner cases (e.g., when using messages that are 511, 512, or 513 bytes long),
and when commands include arbitrary amounts of whitespace. This is not specified in the RFC,
but most production IRC servers are able to deal with the kind of messages sent by the
"Robustness" tests.