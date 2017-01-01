.. _chirc-assignment3:

Assignment 3: Channels and Modes
================================

In this part of the project, your main goal will be to add support for
channels and modes. You will now have to deal with the fact that
messages may be relayed to multiple users, sometimes across multiple
channels.

The parts of this assignment are presented in suggested order of
implementation. Nonetheless, once you’ve implemented channels (``JOIN``,
``PART``, and sending messages to channels), implementing modes and the
remaining messages are all fairly independent of each other.

``JOIN``
--------

Implement the ``JOIN`` command, as described in `[RFC2812 §3.2.1] <http://tools.ietf.org/html/rfc2812#section-3.2.1>`__, with the
following exceptions:

-  The command must accept a single parameter: a channel name.

-  You must only support the ``RPL_TOPIC`` and ``RPL_NAMREPLY`` replies.

Take into account the following:

-  You must only send a ``RPL_TOPIC`` reply if the channel has a topic
   (you will implement the ``TOPIC`` message later). Otherwise, that
   reply is skipped.

-  Although not stated explicitly in `[RFC2812 §3.2.1] <http://tools.ietf.org/html/rfc2812#section-3.2.1>`__, the
   ``RPL_NAMREPLY`` reply must be followed by a ``RPL_ENDOFNAMES``. Basically, you are
   sending the same replies generated when a ``NAMES`` message (with
   this channel as a parameter) is received.

-  The first automated tests for ``JOIN`` will check that the
   ``RPL_NAMREPLY`` and ``RPL_ENDOFNAMES`` replies are sent, but won’t
   validate their contents. So, you can get away with just sending the
   following replies (substituting ``nick`` with the recipient nick)::

      :hostname 353 nick = #foobar :foobar1 foobar2 foobar3
      :hostname 366 nick #foobar :End of NAMES list

   Once you implement the ``NAMES`` message, you can simply substitute
   this with a call to the same code that handles the ``NAMES`` message.
   Note that, until you implement ``NAMES`` correctly, most IRC clients
   will show your channels as having the three users in your hardcoded
   ``NAMES`` reply (``foobar1``, ``foobar2``, and ``foobar3``)

``PRIVMSG`` and ``NOTICE`` to channels
--------------------------------------

Extend your implementation of ``PRIVMSG`` and ``NOTICE`` from the previous assignment
to support sending messages to a channel.

Until you implement modes, you will not need to support any additional
replies in ``PRIVMSG``. However, take into account the following:

-  Despite its name, the ``ERR_NOSUCHNICK`` is also the appropriate reply
   when a non-existent channel is specified.

-  Users cannot send ``PRIVMSG`` and ``NOTICE`` messages to channels
   they have not joined. When this happens, a ``ERR_CANNOTSENDTOCHAN``
   reply must be sent back (only in the case of ``PRIVMSG`` messages).

-  Once you have implement modes, there may be additional cases where a
   message will be denied if the user has insufficient privileges to
   speak on a channel.

``PART``
--------

Implement the ``PART`` command, as described in `[RFC2812 §3.2.2] <http://tools.ietf.org/html/rfc2812#section-3.2.2>`__, with the
following exceptions:

-  The command must accept either one parameter (a channel name) or two
   parameters (a channel name and a parting message)

-  You must only support the ``ERR_NOTONCHANNEL`` and
   ``ERR_NOSUCHCHANNEL`` replies.

Take into account the following:

-  Once all users in a channel have left that channel, the channel must
   be destroyed.

``TOPIC``
---------

Implement the ``TOPIC`` command, as described in `[RFC2812 §3.2.4] <http://tools.ietf.org/html/rfc2812#section-3.2.4>`__, with the
following exceptions:

-  You only need to support the ``ERR_NOTONCHANNEL``, ``RPL_NOTOPIC``,
   and ``RPL_TOPIC`` replies.

-  You will not need to support the ``ERR_CHANOPRIVSNEEDED`` reply until
   you implement modes.

User and channel modes
----------------------

In IRC, users can have certain *modes* assigned to them. Modes are
identified by a single letter, and they are binary: a user either has a
mode, or he doesn’t. The possible user modes are described in `[RFC2812 §3.1.5] <http://tools.ietf.org/html/rfc2812#section-3.1.5>`__, and we
will be implementing only the following modes:

- ``a`` -- The *away* mode. Users with this mode are considered to be “away
  from IRC”. Besides being displayed as such on an IRC client, it will
  also affect how certain messages directed to a user will be
  processed.
- ``o`` -- The *operator* mode. Users with this mode have administrative
  privileges on the IRC server, and have access to certain commands
  available only to operators.

The above two modes are global modes: they have effect across the entire
server. Users can also have channel-specific modes (or *member status*
modes, see `[RFC2811 §4.1] <http://tools.ietf.org/html/rfc2811#section-4.1>`__). We will be
implementing the following member status modes:

- ``o`` -- The *channel operator* mode. Users with this mode on a channel
  have special privileges on that channel.

- ``v`` -- The *voice* mode. Users with this mode are able to send messages
  to moderated channels (described below).

Finally, channels themselves can also have modes (see `[RFC2811 §4] <http://tools.ietf.org/html/rfc2811#section-4>`__). We will be
implementing the following modes:

- ``m`` -- The *moderated* mode. When a channel has this mode, only certain
  users are allowed to send messages to the channel.

- ``t`` -- The *topic* mode. When a channel has this mode, only a channel
  operator can set the channel’s topic.

These modes are managed with the ``OPER``, ``MODE``, and ``AWAY``
commands. For now, we will focus on the first two.

You must implement the ``OPER`` message as described in `[RFC2812 §3.1.4] <http://tools.ietf.org/html/rfc2812#section-3.1.4>`__, with the
following exceptions:

-  You must only support the ``RPL_YOUREOPER`` and
   ``ERR_PASSWDMISMATCH``.

Take into account that you should expect a ``<user>`` parameter but will
ignore its content; the password expected by the ``OPER`` command is the
one specified in the ``-o`` command-line parameter to the ``chirc``
executable.

You must implement the ``MODE`` message as described in `[RFC2812 §3.1.5] <http://tools.ietf.org/html/rfc2812#section-3.1.5>`__ (for user
modes) and `[RFC2812 §3.2.3] <http://tools.ietf.org/html/rfc2812#section-3.2.3>`__ (for member
status and channel modes), with the following exceptions:

-  For user modes:

   -  You only need to support two (and only two) parameters: the nick
      and the mode string. The mode string will always be two characters
      long: a plus or minus character, followed by a letter.

   -  You only need to support the ``ERR_UMODEUNKNOWNFLAG`` and
      ``ERR_USERSDONTMATCH`` replies.

   -  If there are no errors, the reply to the ``MODE`` message will be
      a relay of the message, prefixed by the user’s nick and with the
      mode string in a long parameter. So, if a user sends this message::

         MODE jrandom -o

      The reply should be::

         :jrandom MODE jrandom :-o

-  For channel modes:

   -  When only a single parameter (a channel name) is used, the only
      error condition you must support is the ``ERR_NOSUCHCHANNEL``
      reply (although this is not included in the specification for
      ``MODE``). If the command is successful, return a
      ``RPL_CHANNELMODEIS`` reply (in this reply, the ``<mode>``
      parameter must be a plus sign followed by the channel modes; you
      must omit the ``<mode params>`` parameter).

   -  When two parameters (a channel name and a mode string) are used,
      you must support the following error replies:
      ``ERR_NOSUCHCHANNEL``, ``ERR_CHANOPRIVSNEEDED``, and
      ``ERR_UNKNOWNMODE``. If the command is successful, the message is
      relayed back to the user and to all the users in the channel.

-  For member status modes:

   -  You only need to support three parameters: the channel, the mode
      string, and the nick.

   -  You must support the following error replies:
      ``ERR_NOSUCHCHANNEL``, ``ERR_CHANOPRIVSNEEDED``,
      ``ERR_UNKNOWNMODE``, and ``ERR_USERNOTINCHANNEL``.

   -  If the command is successful, the message is relayed back to the
      user and to all the users in the channel.

You must observe the following rules when dealing with modes:

-  The ``OPER`` message is the *only* way for a user to gain operator
   status (the ``o`` user mode). As indicated in the specification, a
   request for ``+o`` by a non-operator should be ignored.

-  The ``a`` user mode cannot be toggled using the ``MODE`` command.
   Only the ``AWAY`` message can manipulate that mode. Requests to
   change it should be ignored.

-  When a channel is created (when the first user enters that channel),
   that user is automatically granted the channel operator mode.

-  In a channel, only a channel operator can change the channel modes.

-  In a channel, only a channel operator can change the member status
   modes of users in that channel.

-  When a channel has the ``m`` mode, only channel operators and users
   with the ``v`` member status can send ``PRIVMSG`` and ``NOTICE``
   messages to that channel. Other users will receive an
   ``ERR_CANNOTSENDTOCHAN`` reply.

-  When a channel has the ``t`` mode, only channel operators can change
   the channel’s topic. Other users will receive a
   ``ERR_CHANOPRIVSNEEDED`` reply.

-  In terms of permissions, server operators (i.e., with user mode
   ``o``) are assumed to have the same privileges as a channel operator.
   However, a server operator *does not* explicitly receive the ``o``
   member status upon joining a channel (the user will simply have,
   implicitly, the same privileges as a channel operator).

``AWAY``
--------

Implement the ``AWAY`` command, as described in `[RFC2812 §4.1] <http://tools.ietf.org/html/rfc2812#section-4.1>`__.

``NAMES``
---------

Implement the ``NAMES`` command, as described in `[RFC2812 §3.2.5] <http://tools.ietf.org/html/rfc2812#section-3.2.5>`__, with the
following exceptions:

-  We are not supporting invisible, private, or secret channels, so you
   can consider that all channels are visible to a user sending the
   ``NAMES`` command.

-  You only need to support ``NAMES`` messages with no parameters or
   with a single parameter.

   -  When no parameters are specified, you must return a
      ``RPL_NAMREPLY`` reply for each channel. Since we are not
      supporting invisible users, the final ``RPL_NAMREPLY`` must
      include the names of all the users who are not on any channel. If
      all connected users are in a channel, this final ``RPL_NAMREPLY``
      is omitted.

   -  When a single parameters is specified, that parameter is
      interpreted to be a channel.

-  You do not need to support the ``ERR_TOOMANYMATCHES`` and
   ``ERR_NOSUCHSERVER`` replies.

Take into account the following:

-  Channels and nicks do not need to be listed in any specific order.

-  When you implement modes, nicks with channel operator privileges on a
   channel must have their nick prefixed by ``@`` in the
   ``RPL_NAMREPLY`` reply. Similarly, nicks with “voice” privileges must
   have their nick prefixed by ``+``.

``LIST``
--------

Implement the ``LIST`` command, as described in `[RFC2812 §3.2.6] <http://tools.ietf.org/html/rfc2812#section-3.2.6>`__, with the
following exceptions:

-  You only need to support ``LIST`` messages with no parameters (list
   all channels) or with a single parameter (list only the specified
   channel).

-  You do not need to support the ``ERR_TOOMANYMATCHES`` and
   ``ERR_NOSUCHSERVER`` replies.

Take into account the following:

-  Channels do not need to be listed in any specific order.

-  In the ``RPL_LIST`` reply, the ``<# visible>`` refers to the total
   number of users on that channel (since we are not supporting
   invisible users, the number of visible users equals the total number
   of users in the channel).

``WHO``
-------

Implement the ``WHO`` command, as described in `[RFC2812 §3.6.1] <http://tools.ietf.org/html/rfc2812#section-3.6.1>`__, with the
following exceptions:

-  If a mask is specified, you only need to support the case where the
   mask is the name of a channel. If such channel exists, you must
   return a ``RPL_WHOREPLY`` for each user in that channel.

-  We are not supporting invisible clients so, if no mask is specified
   (or if ``0`` or ``*`` is specified as a mask), you must return a
   ``RPL_WHOREPLY`` for each user in the server that doesn’t have a
   common channel with the requesting client.

-  You do not need to support the ``o`` parameter.

-  You do not need to support the ``ERR_NOSUCHSERVER`` reply.

Take into account the following:

-  When a channel is not specified, the ``<channel>`` field in the
   ``RPL_WHOREPLY`` reply must be set to ``*``.

-  In the ``RPL_WHOREPLY`` reply, the ``<hopcount>`` should be hardcoded
   to ``0`` (zero).

-  The ``RPL_WHOREPLY`` must return a series of flags, which is
   specified as ``( "H" / "G" > ["*"] [ ( "@" / "+" ) ]`` without
   explanation (furthermore, the ``>`` is a typo, and should be a right
   parenthesis). The flags must be constructed thusly, in this order:

   -  If the user is not away, include ``H`` (“here”)

   -  If the user is away, include ``G`` (“gone”)

   -  If the user is an operator, include ``*``

   -  If the user is a channel operator, include ``@``

   -  If the user has the voice mode in the channel, include ``+``

   When a channel is not specified, the ``@`` and ``+`` flags are not
   included (regardless of what channel modes that user may have in the
   users he belongs to).

Updating commands from previous assignment
------------------------------------------

Update the implementation of the following commands:

-  ``NICK``: When a user sends this message, and the change of nick is
   successful, it must be relayed to all the channels that user is in.

-  ``QUIT``: When a user sends this message, it must be relayed to all
   the channels that user is in. Take into account that a ``QUIT``
   results in that user leaving all the channels he is in.

-  ``WHOIS``: Add support for the ``RPL_WHOISOPERATOR``,
   ``RPL_WHOISCHANNELS``, and ``RPL_AWAY`` replies. These are only sent
   if the user is an IRC operator, on at least one channel, or away,
   respectively. The order of all the replies will be:
   ``RPL_WHOISUSER``, ``RPL_WHOISCHANNELS``, ``RPL_WHOISSERVER``,
   ``RPL_AWAY``, ``RPL_WHOISOPERATOR``, ``RPL_ENDOFWHOIS``.

-  ``LUSERS``: The replies need to be updated to show the correct number 
   of IRCops and the number of channels.
