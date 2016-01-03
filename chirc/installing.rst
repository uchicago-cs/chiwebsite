.. _chirc-build:

Installing, Building, and Running chirc
=======================================

The source code for chirc can be found in the following GitHub repository:

    https://github.com/uchicago-cs/chirc

To work on the assignments, all you need to do is clone this repository. However,
please note that your instructor may give you more specific instructions on how
to get the chirc code.

Software Requirements
---------------------

chirc itself has not special software requirements beyond a standard C compiler and the
standard C library. However, the automated tests (described in :ref:`chirc-testing`) require
the following software:

* Python 3.4 or above
* `py.test <http://pytest.org>`_, including plugins ``pytest-html`` and ``pytest-json``. All of these can be
  installed using pip (``pip3 install pytest pytest-html pytest-json``)


Building
--------

Once you have the chirc code, you can build it simply by running Make::

   make

This will generate an executable called ``chirc`` that accepts the following
parameters:

* ``-p``: The port on which the server will listen.
* ``-o``: To specify the "operator password".
* ``-q``, ``-v``, or ``-vv``: To control the level of logging. See "Logging" section below. 

To modify the code, you should *only* add files to the ``src/``
directory. Take into account that, if you add additional ``.c`` files,
you will need to modify the ``Makefile`` file so they will be
included in the build (more specifically, you will need to include a new
object file in the ``OBJS`` variable).


Running
-------

You need to run the executable with at least the ``-o``
option, although this option will not be relevant until Project 1c. For
example::

   ./chirc -o foobar

The provided code, however, doesn’t do anything other that process the
command-line parameters. You should nonetheless verify that it builds
and runs correctly.

Note: your code *must* respect the values specified in the command-line
parameters. More importantly, if you do not use the port specified in
the ``-p`` parameter, your code will fail all the automated tests.

Logging
-------

The chirc server prints out messages to standard output using a
simple logging function called ``chilog()``, declared in ``src/log.h``. 
If you need to print messages to standard output, you *must* use the
``chilog()`` function. This is a simple function that expects the 
same parameters as ``printf``, plus an additional parameter to specify a logging level.
For example:

.. code-block:: c

    chilog(INFO, "User with nick %s has connected", nick);

**Do not use printf() directly in your code. Use only chilog() to print messages to standard output.**

The first parameter to ``chilog()`` is used to specify the log level:

-  ``CRITICAL``: Used for critical errors for which the only solution is to
   exit the program.

-  ``ERROR``: Used for non-critical errors, which may allow the program to
   continue running, but a specific part of it to fail (e.g., an individual
   socket).

-  ``WARNING``: Used to indicate unexpected situation which, while not
   technically an error, could cause one.

-  ``INFO``: Used to print general information about the state of the program.

-  ``DEBUG``: Used to print detailed information about the state of the
   program.

-  ``TRACE``: Used to print low-level information, such as function
   entry/exit points, dumps of entire data structures, etc.

The level of logging is controlled by the ``q`` and ``-v`` argument when running
``chirc``:

-  No ``-q`` or ``-v`` argument: Print only ``CRITICAL``, ``ERROR``, ``WARNING`` and ``INFO`` messages.

- ``-v``: Also print ``DEBUG`` messages.

- ``-vv``: Also print ``TRACE`` messages.

- ``-q``: Quiet mode. No logging messages will be printed at all.

Using ``chilog()`` instead of ``printf()`` will make it easy for you to control the level of
verbosity in your logging without having to add and/or comment out ``printf()`` statements.
