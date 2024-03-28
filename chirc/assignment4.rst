.. _chirc-assignment4:

Assignment 4: Abridged version of Assignments 2 and 3
=======================================================

As an alternative to doing Assignments 2 and 3, you can do an abridged version of those assignments that will still implement enough of the functionality required to move on
to Assignment 5.

In this assignment, you should follow the instructions provided in Assignments 2 and 3, but can skip the following:

- Do not implement the ``MOTD`` command. Please note that you still need to send a ``ERR_NOMOTD`` as part of the welcome messages.
- Do not implement the ``TOPIC`` command. You also do not need to support the ``RPL_TOPIC`` reply in other commands.
- Do not implement the ``NAMES`` command. Note that you still need to send the ``RPL_NAMREPLY`` replies after a ``JOIN``, but you can implement that directly in your implementation of ``JOIN``.
- Do not implement the ``WHO`` command.
- You do not need to pass the "Robustness" tests, and they will not contribute to your score.

You can also assume that any part of Assignments 2 and 3 that depends on the above commands can be skipped.
For example, the ``LIST`` command would ordinarily print the topics of each channel but, since we won't
be supporting the ``TOPIC`` command, you can assume that no topic would be included in the ``RPL_LIST`` replies.

