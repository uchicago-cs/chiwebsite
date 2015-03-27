.. _chidb-installing:

Installing, Building, and Running chidb
=======================================

The source code for chidb can be found in the following GitHub repository:

    https://github.com/uchicago-cs/chidb

To work on the assignments, all you need to do is clone this repository. However,
please note that your instructor may give you more specific instructions on how
to get the chidb code.

Software Requirements
---------------------

chidb has a number of software requirements. If you are doing the chidb assignments
as part of a class, it's likely that this software is already installed on your
school's computers. If so, you can skip this section, unless you want to run chidb
on your own computer.


Autotools
~~~~~~~~~

Building the chidb code requires the GNU build system (commonly referred to as
“Autotools”). Although you do not need to understand how the GNU build system
toolchain works, you do need the following tools installed on your machine:

-  ``automake``

-  ``autoconf``

-  ``libtool``

-  Check Unit Test Framework (http://check.sourceforge.net/).

These tools are typically installed by default on most UNIX systems, and also
available as packages.

Other dependencies
~~~~~~~~~~~~~~~~~~

chidb also requires that the following tools or libraries be installed:

- `lex <http://en.wikipedia.org/wiki/Lex_(software)>`_
- `yacc <http://en.wikipedia.org/wiki/Yacc>`_
- `Editline library <http://thrysoee.dk/editline/>`_, including the header files.

These tools are *not* typically installed by default on most UNIX systems,
but they are readily available as packages on most package managers.

Building
--------

The first time you download the chidb code to your machine, you must run the
following from the root of the chidb code tree:

::

    ./autogen.sh 

This will verify whether you have the necessary tools to build chidb and will
also generate a number of files.

Next, run the following:

::

    ./configure

This will verify whether your machine has all the necessary libraries to build
chidb. More specifically, you will see errors if Check, Lex, Yacc, or Editline
are not installed.

You only need to run ``./configure`` once. Once it has run successfully, you
will be able to build the chidb code by running:

::

    make

By default, ``make`` will only print the names of the files it is building. To
enable a more verbose output (including the exact commands that make is running
during the build process), just run ``make`` like this:

::

    make V=1

This will generate two files:

-  ``chidb``: The chidb shell (described in :ref:`chidb-testing`)

-  ``./.libs/libchidb.so`` and ``./.libs/libchisql.so``: The ``libchidb`` and
   ``libchisql`` libraries. Any applications that wants to use the chidb API
   calls must link with these libraries. It is also possible to link only with
   chidb's SQL parser, although the API for this is currently not documented.


Running
-------

To check whether chidb built correctly, just run the following::

       ./chidb

You should see the following prompt::

   chidb>

Take into account that you won't be able to do much with the ``chidb`` shell until 
you've implemented substantial portions of the project. :ref:`chidb-testing` describes
ways in which you can test your code *before* it's complete enough for the shell to work.


