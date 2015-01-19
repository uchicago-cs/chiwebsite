Installing and Building chiTCP
==============================

Software Requirements
---------------------

Autotools
~~~~~~~~~

Building the chiTCP code requires the GNU build system (commonly
referred to as “Autotools”). Although you do not need to understand how
the GNU build system toolchain works, you do need the following tools
installed on your machine:

-  ``automake``

-  ``autoconf``

-  ``libtool``

-  Check Unit Test Framework (http://check.sourceforge.net/).

These tools are typically installed by default on most UNIX systems, and
also available as packages.

``protobuf`` and ``protobuf-c``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

chiTCP requires at least ``protobuf`` 2.6.1 and ``protobuf-c`` 1.0.2. 
If these versions are not available as packages on your
operating system, you will need to install from source. You can find the
appropriate tarballs at http://code.google.com/p/protobuf/ and
http://code.google.com/p/protobuf-c/.

On most UNIX systems, you should be able to install ``protobuf`` by
running the following:

::

   wget https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz
   tar xvzf protobuf-2.6.1.tar.gz 
   cd protobuf-2.6.1/
   ./configure --prefix=/usr
   make
   sudo make install

And ``protobuf-c`` by running the following:

::

   wget https://github.com/protobuf-c/protobuf-c/releases/download/v1.0.2/protobuf-c-1.0.2.tar.gz
   tar xvzf protobuf-c-1.0.2.tar.gz 
   cd protobuf-c-1.0.2/
   ./configure --prefix=/usr
   make
   sudo make install

Please note the use of ``--prefix=/usr``. If you omit this parameter, the
libraries will be installed in ``/usr/local/lib``, which can cause
problems on some systems. If you encounter an error like this:

::

    error while loading shared libraries: libprotoc.so.N: cannot open shared object file: 
                                                                           No such file or directory

you will need to explicitly add ``/usr/local/lib`` (or any alternate
prefix you specify when installing) to the ``LD_LIBRARY_PATH``
environment variable:

::

    export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib


Building
--------

The first time you download the chiTCP code to your machine, you must
run the following from the root of the chiTCP code tree:

::

    ./autogen.sh 

This will verify whether you have the necessary tools to build chiTCP
and will also generate a number of files.

Next, run the following:

::

    ./configure

This will verify whether your machine has all the necessary libraries to
build chiTCP. More specifically, you will see errors if Check, ``protobuf``,
or ``protobuf-c`` are not installed.

You only need to run ``./configure`` once. Once it has run successfully,
you will be able to build the chiTCP code by running:

::

    make

By default, ``make`` will only print the names of the files it is
building. To enable a more verbose output (including the exact commands
that make is running during the build process), just run ``make`` like
this:

::

    make V=1

This will generate two files:

-  ``chitcpd``: The chiTCP daemon. You can verify that it works
   correctly by running the following:

   ::

       ./chitcpd -v

   You should see the following output:

   ::

       [2014-02-02 11:36:07]   INFO lt-chitcpd chitcpd running. UNIX socket: /tmp/chitcpd.socket. TCP socket: 23300

   Note that, by default, ``chitcpd`` will run on port 23300. You can
   specify an alternate port using the ``-p`` option.

-  ``./.libs/libchitcp.so``: The ``libchitcp`` library. Any applications
   that want to use the chisocket library will need to link with this
   library.

The chiTCP code also includes a few sample programs that use the
chisocket library. They can be built like this:

::

    make samples

The sample executables will be generated in the ``samples`` directory.

