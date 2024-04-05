.. _chirc-assignment5:

Assignment 5: IRC Networks
==========================

Up to this point, you have been adding support for client-to-server communications, where there is a single IRC server and multiple clients connecting to it. In this assignment, you will add support for *IRC networks* composed of multiple servers. The notion of an IRC network is (briefly) introduced in `[RFC2810 §3] <https://tools.ietf.org/html/rfc2810#section-3>`__, and the server-to-server part of the IRC protocol is defined in `[RFC2813] <https://datatracker.ietf.org/doc/html/rfc2813>`__.

In a nutshell, an IRC network is a collection of IRC servers where each server maintains an (essentially) identical list of users and channels, and any changes (e.g., someone joining a channel) are propagated to the other servers in the network. For example, the diagram shown in `[RFC2810 §3] <https://tools.ietf.org/html/rfc2810#section-3>`__ presents a network with five servers (A, B, C, D, E). Two clients (1 and 2) are connected to server A, while clients 3 and 4 are connected to B and D respectively.

::

                       1--\
                           A        D---4
                       2--/ \      /
                             B----C
                            /      \
                           3        E

   Servers: A, B, C, D, E         Clients: 1, 2, 3, 4

If client 1 were to join channel ``#foobar``, A would propagate this information to B, who would then propagate it to C, who would then propagate it to both D and E. So, if client 4 was already in ``#foobar``, they would see client 1 join that channel, even though client 1 and 4 are connected to different servers.

So, an IRC network gives clients the impression that they are dealing with a single system, even though there are actually multiple servers in the network. From a client's perspective, it doesn't matter what server they connect to, as they should all have the same information (same list of users and channels, etc.). However, by having multiple servers, our IRC network can support more users.

Of course, this also comes with challenges. An IRC network is a simple example of a distributed system that needs to ensure consistency amongst its servers. If a message is dropped between two servers, or if a connection is severed, we could end up in an inconsistent state (e.g., where one server thinks that channel ``#foobar`` has some set of users, while another server thinks it has some other set of users). In this assignment, we are not going to concern ourselves with these scenarios, which are beyond the scope of this assignment, and we will focus on implementing the aspects of the IRC protocol that allow us to set up an IRC network. However, doing so can give you an appreciation for why distributed systems can be challenging to implement.

So, we will be making the following simplifying assumptions:

- Communications between servers are reliable: there are no dropped messages, and connections between the servers do not get interrupted.
- The servers that make up the IRC network are known in advance: previously unknown servers cannot dynamically join our IRC network. This is actually a common assumption in production IRC networks, where network administrators only allow a pre-approved set of servers to join the network.
- Loops cannot be formed between servers (i.e., servers always connect in a spanning tree, as required by the IRC specification), and we do not have to detect or react to loops in server connections.
- In fact, our testing will be limited to just two servers.

The network specification file
------------------------------

In chirc, an IRC network is specified via a *network specification file*. This is a simple CSV file like this::

    irc-1.example.net,127.0.0.1,6667,pass1
    irc-2.example.net,127.0.0.1,6668,pass2

Each row corresponds to one server, and contains the following fields:

- **Server name** (e.g., ``irc-1.example.net``): A name that uniquely identifies the server. While a hostname is typically used, you should not treat it like a hostname (i.e., you should not try to connect to a server via its server name). The server name should be treated as a string identifier.
- **Hostname or IP address** (e.g., ``127.0.0.1``): The hostname or IP address that we can use to connect to the server.
- **Port** (e.g., ``6667``): The port we can use to connect to the server.
- **Server Password** (e.g., ``pass1``): Each server has an associated password. Other servers must supply this password to connect to the server.

The ``chirc`` executable accepts an ``-n`` option to specify a network specification file, and an ``-s`` file to specify what server from that network should be run by ``chirc``. For example, suppose the above network specification file is named ``2servers.txt``. We would start the first server like this::

    ./chirc -n 2servers.txt -s irc-1.example.net -o operpasswd

This would start a server on port ``6667`` (the port specified for ``irc-1.example.net``). When starting the server, we do not take the hostname/IP into consideration, as that is only used when establishing connections between servers. Also note how we still have to specify an operator password, which is distinct from the server password.

Similarly, we would start the second server like this::

    ./chirc -n 2servers.txt -s irc-2.example.net -o operpasswd

This would start a server on port ``6668``. Note how we don't specify a port using the ``-p`` option (the port is always taken from the network specification file).

``PASS`` and ``SERVER``
-----------------------

Similar to how a user registers by sending a ``NICK`` and ``PASS`` command, a server connects to another server by sending a ``PASS`` and ``SERVER`` commands. We will refer to the server that initiates the connection (i.e., the one that sends ``PASS`` and ``SERVER``) as the *active* server, and we will refer to the one that receives the connection as the *passive* server.

You must add support for these commands, as specified in `[RFC2813 §4.1.1] <https://tools.ietf.org/html/rfc2813#section-4.1.1>`__ and `[RFC2813 §4.1.2 <https://tools.ietf.org/html/rfc2813#section-4.1.2>`__].

Take into account the following:

- When receiving a ``PASS`` command, you only need to look at the ``<password>`` parameter, which must match the passive server's password. You can ignore the other parameters.
- When receiving a ``SERVER`` command, you only need to look at the ``<servername>`` parameter, which will be the server name of the active server. You can ignore the other parameters.
- Once *both* commands are received, you must send back an ``ERROR`` message in the following cases:

  - If the ``PASS`` command included an incorrect password::

        ERROR :Bad password

  - If the ``SERVER`` command included a server name that is not part of the network::

        ERROR :Server not configured here

  - If the ``SERVER`` command included a server name that has already connected to the passive server::

        ERROR :ID "<servername>" already registered

- Once both commands are received, you must send back a ``PASS`` and ``SERVER`` message to the active server, providing the active server's password in ``PASS`` and the passive server's server name in ``SERVER``. Additionally, these ``PASS`` and ``SERVER`` messages must have a prefix containing the passive server's server name.

  - In the ``PASS`` commmand, the ``<password>`` must be the *active* server's password, the ``<version>`` must be ``0210`` and the ``<flags>`` must be a string of the form ``chirc|XXX`` (where ``XXX`` can be any version identifier, such as ``0.1``, ``3.11``, etc.).

  - In the ``SERVER`` command, the ``<servername>`` must be the *passive* server's name. The ``<hopcount>`` and ``<token>`` should be set to ``1`` and the ``<serverinfo>`` can be any arbitrary string.


For example, suppose ``irc-2.example.net`` wanted to connect to ``irc-1.example.net``. It would send these messages::

    PASS pass1 0210 chirc|0.6
    SERVER irc-2.example.net 1 1 :chirc server

You can read these as "Hello server, I am ``irc-2.example.net`` and I wish to connect to you. Your password is ``pass1``"

``irc-1.example.net`` will then reply with the following::

    :irc-1.example.net PASS pass2 0210 chirc|0.6
    :irc-1.example.net SERVER irc-1.example.net 1 1 :chirc server

You can read this reply as "Hello server, I would also like to connect with you. I am ``irc-1.example.net``. Your password is ``pass2``"

``NICK``
--------

You must implement the server-to-server form of the ``NICK`` command specified in `[RFC2813 §4.1.2 <https://tools.ietf.org/html/rfc2813#section-4.1.2>`__]. Whenever a user connects to a server, the server will send this special form of the ``NICK`` command to all the servers it is connected to, to notify them that a new user has joined the network. So, if you receive such a ``NICK`` command, you should add the user to the server's list of users (but taking into account that this represents a user connected to a different server).

Take into account the following:

- You can set ``<hopcount>`` and ``<servertoken>`` to always be ``1``.
- You can set ``<umode>`` to be ``+``.

.. note::

   Ordinarily, a server registration is followed by each server sending a ``NICK`` command for every user that is already connected to the server (to inform the other server of the users it currently has). You do not have to do this, and we do not currently test for this. You only need to send a ``NICK`` command to the other servers when a *new* user connects to a server.

``CONNECT``
-----------

You will be able to test the ``PASS``, ``SERVER``, and ``NICK`` command by running a single server and having a client pretend to be another server (in fact, several of the tests do just this). However, to create an actual IRC network, we will need one server to connect to another. This is done using the ``CONNECT`` command specified in `[RFC2812 §3.4.7 <https://tools.ietf.org/html/rfc2812#section-3.4.7>`__].

Take into account the following:

- ``<target server>`` will include a *server name* (not a hostname).

- You must ignore the ``<port>`` parameter, as the server's port is specified in the network specification file.

- You will not be supporting the ``<remote server>`` parameter.

- If the parameters are correct, but you're still unable to connect to the other server, the IRC specification does not mandate any sort of reply or error message (i.e., the ``CONNECT`` command will simply fail silently). You should nonetheless print a log message in your server to indicate this has happened.

- Similarly, if you are able to connect successfully, the IRC specification does not mandate any sort of reply confirming the connection has been successful.

- If the connection is successful, you should spawn a thread to handle that connection, in the same way you spawn a thread to handle a new connection from a client (the main difference is that, in this case, the server is the one that initiates the connection).

Relaying Commands
-----------------

Once two servers are connected, they must relay information to ensure their internal state is coherent. For simplicity, we will always relay information to all servers (with a few exceptions). This means that you do not need to figure out the exact servers that certain information should be relayed to (e.g., if a server is connected to five other servers, and a message is intended for a user in one of those servers, we don't need to determine the exact server to relay it to; we just relay it to all of them).

You must relay the following commands:

- User registrations: When a new user registers, you must send a server-to-server ``NICK`` message to all servers, as described earlier.
- ``PRIVMSG`` to users: you must relay all ``PRIVMSG`` messages intended for users who are not in the same server as the sending user. ``PRIVMSG`` messages between users in the same server should *not* be relayed.
- ``JOIN``: you must relay all ``JOIN`` messages.
- ``PRIVMSG`` to channels:  You must relay all ``PRIVMSG`` messages to channels, even if all the users are in the same server and a relay would be unnecessary.

When relaying a message to another server, the message itself should not be modified in any way, but the prefix should include *only* the nick of the originating user. So, suppose a server receives the following from a client (registered with nick ``jrandom``)::

    PRIVMSG #test :Hello, everyone!

This would be relayed to other clients like this::

    :jrandom!jrandom@unix.example.net PRIVMSG #test :Hello, everyone!

But it would be relayed to other *servers* like this::

    :jrandom PRIVMSG #test :Hello, everyone!

Note: You will be able to test your implementation of relayed commands before implementing ``CONNECT`` (we have included tests for this that don't rely on ``CONNECT``)

Querying the Network's State
----------------------------

Finally, you must update a few commands to ensure that they are correctly showing information about the IRC network:

- ``WHOIS``: The ``<servername>`` parameter in the ``RPL_WHOISSERVER`` reply must include the server name of the server that the user is connected to.
- ``LUSERS``: The ``RPL_LUSERCLIENT`` reply must specify the number of users and servers across the entire IRC network. The ``RPL_LUSERME`` must include the number of clients and servers directly connected to the server receiving the ``LUSERS`` command.  The number of unknown connections in ``RPL_LUSERUNKNOWN`` refers only to those in the server receiving the ``LUSERS`` command.
- ``LIST``: The ``LIST`` command should list channels across the entire IRC network.
