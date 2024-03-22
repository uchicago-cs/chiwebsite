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

chirc has the following software requirements:

* `CMake <https://cmake.org/>`__ (version 3.5.1 or higher)
* Python 3.8 or above
* `py.test <http://pytest.org>`_, including plugins ``pytest-html`` and ``pytest-json``. All of these can be
  installed using pip (``pip3 install pytest pytest-html pytest-json``)


Building
--------

The first time you download the chirc code to your machine, you must run the
following from the root of the chirc code tree::

    cmake -B build/

This will create a ``build`` directory containing several files necessary to build and test chirc.

Once you have done this, simply run ``make`` inside the ``build`` directory
to build chirc::

    cd build/
    make

This will generate the ``chirc`` executable.

You should follow these conventions when modifying the provided code:

- You are allowed to modify the files inside ``src/``, as well as the ``CMakeLists.txt``
  file. Do *not* modify any other files.
- If you add ``.c`` files to the ``src/`` directory, you must also add that file
  to the list of files specified in the ``add_executable`` command in the ``CMakeLists.txt`` file.
  Otherwise, the file will not be compiled and linked.
- If you want to use third-party libraries, add them inside the ``lib/`` directory
  (do *not* add them in the ``src/`` directory!). If the third-party library has header
  files you need to ``#include`` in your code, *do not* copy the header files into
  the ``src/`` directory. Instead, add the library's directory to the list
  of directories in the ``include_directories`` command in the ``CMakeLists.txt`` file.
  This way, you will be able to ``#include`` header files in those directories.

By default, ``make`` will only print the names of the files it is building. To
enable a more verbose output (including the exact commands that make is running
during the build process), just run ``make`` like this::

    make VERBOSE=1

Running
-------

The ``chirc`` executable accepts the following parameters:

* ``-p``: The port on which the server will listen.
* ``-o``: To specify the "operator password".
* ``-n``: Specifies an IRC network file. This will only be relevant in Assignment 5.
* ``-q``, ``-v``, or ``-vv``: To control the level of logging. See "Logging" section below.

You need to run the executable with at least the ``-o``
option, although this option will not be relevant until the third assignment. For
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
