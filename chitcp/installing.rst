.. _chitcp-installing:

Installing, Building, and Running chiTCP
========================================

The source code for chiTCP can be found in the following GitHub repository:

    https://github.com/uchicago-cs/chitcp

To work on the assignments, all you need to do is clone this repository. However,
please note that your instructor may give you more specific instructions on how
to get the chiTCP code.

Software Requirements
---------------------

chiTCP has a number of software requirements. If you are doing the chiTCP assignments
as part of a class, it's likely that this software is already installed on your
school's computers. If so, you can skip this section, unless you want to run chiTCP
on your own computer. Please note that, so far, chiTCP has only been tested on
Linux systems (including WSL under Windows).

At this point, chiTCP does not build on Mac systems, although we're working on
adding support for Mac systems.


CMake
~~~~~

Building the chiTCP code requires `CMake <https://cmake.org/>`__ (version 3.5.1 or higher)

On Ubuntu systems, you should be able to install it as follows::

    sudo apt install cmake


On a Mac system, you should be able to install it with `Homebrew <https://brew.sh/>`__::

    brew install cmake

``protobuf`` and ``protobuf-c``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

chiTCP requires ``protobuf`` 3.x or higher and ``protobuf-c`` 1.x or higher.

On Ubuntu systems, you should be able to install them as follows::

    sudo apt install protobuf-c-compiler libprotobuf-c1 libprotobuf-c-dev


On a Mac system, you should be able to install these libraries with `Homebrew <https://brew.sh/>`__::

    brew install protobuf-c

On other systems, you will need
to install them from source following the `protobuf instructions <https://github.com/protocolbuffers/protobuf/blob/main/src/README.md>`__
and the `protobuf-c instructions <https://github.com/protobuf-c/protobuf-c/blob/master/README.md>`__.

Criterion Unit Testing Framework
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

chiTCP requires the `Criterion unit testing framework <https://github.com/Snaipe/Criterion>`_
(version 2.3 or higher).

On Ubuntu systems, you should be able to install them as follows::

    sudo apt install libcriterion-dev


On a Mac system, you should be able to install these libraries with `Homebrew <https://brew.sh/>`__::

    brew install criterion

On other systems, you must install the framework manually following their `installation instructions <https://criterion.readthedocs.io/en/latest/setup.html#installation>`__.

.. _chitcp-building:

Building
--------

The first time you download the chiTCP code to your machine, you must run the
following from the root of the chiTCP code tree:

::

    cmake -B build/

This will verify whether you have the necessary tools to build chiTCP and will
also generate a number of files required to build chiTCP. You should only
need to rerun the above commands if you modify CMake's ``CMakeLists.txt``
(which you should not need to do as part of this project).

Once you have done this, simply run ``make`` inside the ``build`` directory
to build chiTCP. This will generate the chiTCP daemon (``chitcpd``), some
sample programs, as well as the test executables (all starting with ``test-``).
Take into account that you must run these programs from inside the ``build``
directory.

By default, ``make`` will only print the names of the files it is building. To
enable a more verbose output (including the exact commands that make is running
during the build process), just run ``make`` like this::

    make VERBOSE=1


Running
-------

To run the chiTCP daemon, just run the following::

       ./chitcpd -vv

You should see the following output::

   [16:57:26.446948795]    INFO          chitcpd chitcpd running. UNIX socket: /tmp/chitcpd.socket. TCP socket: 23300

Take into account that you won't be able to do much with ``chitcpd`` until you've implemented 
the ``tcp.c`` file. We do, however, provide a number of mechanisms for you to test your implementation.
These are described in :ref:`chitcp-testing`

By default, ``chitcpd`` listens on TCP port 23300. If you are running ``chitcpd`` on a shared machine, 
this default value will likely conflict with other users running
on that same machine. To specify an alternate port, you need to set the following environment 
variable on *every* terminal in which you are running chitcp programs (including ``chitcpd`` and any application 
that uses the chisocket library)::

    export CHITCPD_PORT=30287  # Substitute for a different number

``chitcpd`` also creates a UNIX socket on ``/tmp/chitcpd.socket.USER`` (where ``USER`` is your UNIX username). 
It is unlikely that this will conflict with other users but, if you need to specify an alternate location
and name for this UNIX socket, just set the ``CHITCPD_SOCK`` environment variable to the absolute path
of the UNIX socket (and remember to do this on every terminal in which you are running chitcp programs)
