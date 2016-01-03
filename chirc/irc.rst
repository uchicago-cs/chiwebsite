.. _chirc-irc:

Internet Relay Chat
===================

IRC is one of the earliest network protocols for text messaging and
multi-participant chatting. It was created in 1988 and, despite the
emergence of more sophisticated messaging protocols (including open
standards like XMPP and SIP/SIMPLE, and proprietary protocols such as
Microsoft’s MSNP, AOL’s OSCAR, and Skype), IRC remains a popular
standard and still sees heavy use in certain communities, specially the
open source software community.

.. figure:: architecture1.png
   :alt: Basic IRC architecture

   Basic IRC architecture

The basic architecture of IRC, shown in the figure above, is
fairly straightforward. In the simplest case, there is a single *IRC
server* to which multiple *IRC clients* can connect to. An IRC client
connects to the server with a specific identity. Most notably, each
client must choose a unique *nickname*, or “nick”. Once a client is
connected, it can communicate one-to-one with other users. Additionally,
clients can run commands to query the server’s state (e.g., to obtain a
list of connected users, or to obtain additional details about a
specific nick). IRC also supports the creation of chat rooms called
*channels* for one-to-many communication. Users can join channels and
send messages to the channel; these messages will, in turn, be sent to
every user in the channel.

.. figure:: architecture2.png
   :alt: Multi-server IRC architecture

   Multi-server IRC architecture

IRC also supports the formation of *server networks*, where multiple
servers form a tree of connections to support more clients and provide
greater capacity. Servers in the same network share information about
local events (e.g., a new client connects, a user connected to a given
server joins a channel, etc.) so that all servers will have a copy of
the same global state. In this project, we will only consider the case
where there is a single IRC server.

The IRC Protocol
================

The IRC protocol used by IRC servers and clients is a text-based TCP
protocol. Originally specified in 1993
`[RFC1459] <http://tools.ietf.org/html/rfc1459>`__, it was subsequently
specified in more detail in 2000 through the following RFCs:

-  `[RFC2810] <http://tools.ietf.org/html/rfc2810>`__ **Internet Relay
   Chat: Architecture**. This document describes the overall
   architecture of IRC.

-  `[RFC2811] <http://tools.ietf.org/html/rfc2811>`__ **Internet Relay
   Chat: Channel Management**. This document describes how channels are
   managed in IRC.

-  `[RFC2812] <http://tools.ietf.org/html/rfc2812>`__ **Internet Relay
   Chat: Client Protocol**. This document describes the protocol used
   between IRC clients and servers (sometimes referred to as the
   “client-server” protocol)

-  `[RFC2813] <http://tools.ietf.org/html/rfc2813>`__ **Internet Relay
   Chat: Server Protocol**. This document describes the “server-server”
   protocol used between IRC servers in the same network.

You are not expected to read all of these documents. More specifically:

-  We recommend you do read all of
   `[RFC2810] <http://tools.ietf.org/html/rfc2810>`__, as it will give
   you a good sense of what the IRC architecture looks like. You may
   want to give it a cursory read at first, and revisit it as you become
   more familiar with the finer points of the IRC protocol.

-  In Project 1b you will implement a subset of
   `[RFC2812] <http://tools.ietf.org/html/rfc2812>`__. We suggest you
   read `[RFC2812 §1] <http://tools.ietf.org/html/rfc2812#section-1>`__
   and `[RFC2812 §2] <http://tools.ietf.org/html/rfc2812#section-2>`__.
   For the remainder of the RFC, you should only read the sections
   relevant to the parts of the IRC protocol you will be implementing.

-  In Project 1c you will implement a subset of the functionality
   described in `[RFC2811] <http://tools.ietf.org/html/rfc2811>`__,
   which will require implementing additional parts of
   `[RFC2812] <http://tools.ietf.org/html/rfc2812>`__. We suggest you
   hold off on reading
   `[RFC2811] <http://tools.ietf.org/html/rfc2811>`__ until we reach
   Project 1c; if you do want to read the introductory sections, take
   into account that we will only be supporting “standard channels” in
   the “#” namespace, and that we will not be supporting server
   networks.

-  We will not be implementing any part of
   `[RFC2813] <http://tools.ietf.org/html/rfc2813>`__.

Finally, you should take into account that, although IRC has an official
specification, most IRC servers and clients do not conform to these
RFCs. Most (if not all) servers do not implement the full specification
(and even contradict it in some cases), and there are many features that
are unique to specific implementations. In this project, we will produce
an implementation that is partially compliant with these RFCs, and
sufficiently compliant to work with some of the main IRC clients
currently available.

In the remainder of this section, we will see an overview of the message
format used in IRC. Then, in the next section, we will see several
example communications (involving multiple messages between a client and
a server).

Message format
--------------

IRC clients and servers communicate by sending plain ASCII *messages* to
each other over TCP. The format of these messages is described in
`[RFC2812 §2.3] <http://tools.ietf.org/html/rfc2812#section-2.3>`__, and
can be summarized thusly:

-  The IRC protocol is a *text-based* protocol, meaning that messages
   are encoded in plain ASCII. Although not as efficient as a pure
   binary format, this has the advantage of being fairly human-readable,
   and easy to debug just by reading the verbatim messages exchanged
   between clients and servers.

-  A single message is a string of characters with a maximum length of
   512 characters. The end of the string is denoted by a CR-LF (Carriage
   Return - Line Feed) pair (i.e., “``\r\n``”). There is no null
   terminator. The 512 character limit includes this delimiter, meaning
   that a message only has space for 510 useful characters.

-  The IRC specification includes no provisions for supporting messages
   longer than 512 characters, although many servers and clients support
   non-standard solutions (including ignoring the 512 limit altogether).
   In our implementation, any message with more than 510 characters (not
   counting the delimiter) will be truncated, with the last two
   characters replaced with “``\r\n``”.

-  A message contains at least two parts: the command and the command
   parameters. There may be at most 15 parameters. The command and the
   parameters are all separated by a single ASCII space character. The
   following are examples of valid IRC messages::

      NICK amy 
      
      WHOIS doctor 
      
      MODE amy +o 
      
      JOIN #tardis 
      
      QUIT

-  When the last parameter is prefixed with a colon character, the value
   of that parameter will be the remainder of the message (including
   space characters). The following are examples of valid IRC messages
   with a “long parameter”::

      PRIVMSG rory :Hey Rory... 
      
      PRIVMSG #cmsc23300 :Hello everybody 
      
      QUIT :Done for the day, leaving

-  Some messages also include a *prefix* before the command and the
   command parameters. The presence of a prefix is indicated with a
   single leading colon character. The prefix is used to indicate the
   *origin* of the message. For example, when a user sends a message to
   a channel, the server will forward that message to all the users in
   the channel, and will include a prefix to specify the user that sent
   that message originally. We will explain the use of prefixes in more
   detail in the next section.

   The following are examples of valid IRC messages with prefixes::

      :borja!borja@polaris.cs.uchicago.edu PRIVMSG #cmsc23300 :Hello everybody
      
      :doctor!doctor@baz.example.org QUIT :Done for the day, leaving

Replies
-------

The IRC protocol includes a special type of message called a *reply*.
When a client sends a command to a server, the server will send a reply
(except in a few special commands where a reply should not be expected).
Replies are used to acknowledge that a command was processed correctly,
to indicate errors, or to provide information when the command performs
a server query (e.g., asking for the list of users or channels).

A reply is a message with the following characteristics:

-  It always includes a prefix.

-  The command will be a three-digit code. The full list of possible
   replies is specified in `[RFC2812 §5] <http://tools.ietf.org/html/rfc2812#section-5>`__.

-  The first parameter is always the target of the reply, typically a
   nick.

The following are examples of valid IRC replies::

   :irc.example.com 001 borja :Welcome to the Internet Relay Network borja!borja@polaris.cs.uchicago.edu 
   
   :irc.example.com 433 * borja :Nickname is already in use. 
   
   :irc.example.org 332 borja #cmsc23300 :A channel for CMSC 23300 students

