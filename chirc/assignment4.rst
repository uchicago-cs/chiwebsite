.. _chirc-assignment4:

Assignment 4: Abridged version of Assignments 2 and 3
=======================================================

As an alternative to doing Assignments 2 and 3, you can do an abridged version of those assignments that will still implement enough of the functionality required to move on
to Assignment 5.

In this assignment, you should follow the instructions provided in Assignments 2 and 3, with the following modifications:

- Do not implement the ``MOTD`` command.
- You do not need to pass the "Robustness" tests, and they will not contribute to your score.
- Do not implement the ``TOPIC`` command. You also do not need to support the ``RPL_TOPIC`` reply in other commands.
- You will implement a greatly simplified version of "User and channel modes". More specifically:

  - You only need to support the user operator mode and the channel operator mode. This means you do not need to implement a general-purpose mechanism for keeping track of modes in users, channels, and in channel memberships. You are allowed to have some sort of ``is_irc_operator`` flag to keep track of whether a user is an IRC operator or not, and you are allowed to associate some sort of "list of users who are operators in this channel" to keep track of who the channel operators are.
  - The only form of the ``MODE`` command you have to support is the following::

     MODE <channel> <mode> <nick>

    Where ``<mode>`` can only be ``-o`` and ``+o``. You must support replies ``ERR_NOSUCHCHANNEL``, ``ERR_CHANOPRIVSNEEDED``, ``ERR_UNKNOWNMODE``, and ``ERR_USERNOTINCHANNEL``
  - You must support the ``OPER`` command. Once a user becomes an IRC Operator, you can assume they cannot lose that status (that means you do not need to support the command ``MODE <nick> -o``)
  - You do not need to implement the ``AWAY`` command.

- Do not implement the ``NAMES`` command. Note that you still need to send the ``RPL_NAMREPLY`` replies after a ``JOIN``, but you can implement that directly in your implementation of ``JOIN``.
- Do not implement the ``WHO`` command.



