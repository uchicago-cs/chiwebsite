.. _chirouter-automated-tests:

Automated Tests
===============

chirouter includes a set of automated tests that largely mimic the tests
described in the `Testing your Implementation <testing.html>`__ page.
To run the automated tests, just run the following from inside the
``build/`` directory::

   make tests

This will build your code and will run all the tests. To obtain
a summary of how many points you scored on the tests, you must also
run this::

    make grade


Invoking py.test directly
-------------------------

You can have greater control on what tests are run by invoking py.test directly.
When doing so, you must make sure that you've built the latest version of your
code (using the make targets above will do so automatically, but running
py.test directly will not).

Please note that you must run py.test from the root of your repository
(*not* from inside the ``build/`` directory). We suggest you run it like this::

    make && sudo py.test src/python/chirouter/tests/ <PYTEST OPTIONS>

Where ``<PYTEST OPTIONS>`` are the options described in the sections below.
A few parameters that are useful across the board are the following:

- ``-x``: Stop after the first failed test. This can be useful when you're failing
  multiple tests, and want to focus on debugging one failed test at a time.
- ``-s``: Do not suppress output from successful tests. By default, py.test only
  shows the output produced by chirouter if a test fails. In some cases, you may want
  to look at the log messages of a successful test; use this option to force py.test
  to show the output for that test.
- ``--chirouter-loglevel N``: This controls the logging level of the chirouter server run
  by the tests. You can specify the following values for ``N``:

  - ``0``: Corresponds to the default level of logging.
  - ``1``: Corresponds to calling chirouter with the ``-v`` option.
  - ``2``: Corresponds to calling chirouter with the ``-vv`` option.
  - ``3``: Corresponds to calling chirouter with the ``-vvv`` option.

Running categories of tests
---------------------------

If you want to run only a specific category of tests, you can use the
``--chirouter-category`` parameter. For example::

    sudo py.test src/python/chirouter/tests/ --chirouter-category RESPONDING_ARP_REQUESTS

To see the exact categories available in each assignment, run the following
inside the ``build/`` directory::

    make test-categories

Running individual tests
------------------------

If you want to focus on debugging an individual test that is failing, you can
run a single test by using the ``-k`` parameter::

   sudo py.test src/python/chirouter/tests/ -k test_ping_router
   
The name of each failed test can be found after the ``FAILURES`` line in the output
from the tests. For example::

   ===================================== FAILURES =====================================
   _____________________  TestTraceroute.test_traceroute_router _______________________

Debugging a test with a debugger
--------------------------------

If you want to debug a test with a debugger, such as gdb, you will have to run chirouter separately
from the tests (using the debugger), and then instruct the tests to connect to that server (instead of having the
tests launch chirouter on their own).

If using gdb, you would have to run chirouter like this::

    gdb --args ./chirouter -vv -p 23399

This starts chirouter using port 23399 (don't forget to then use gdb's ``run`` command
to actually run the server).

Similarly, if using Valgrind, you would have to run chirouter like this::

    valgrind ./chirouter -vv -p 23399

Next, you will use the ``--chirouter-external-port PORT`` option to instruct py.test to
use the server you're running with a debugger::

    sudo py.test src/python/chirouter/tests/ --chirouter-external-port 23399 -k test_ping_router

Take into account that the ``--chirouter-external-port`` only makes sense when running a single
test, so you will also have to use the ``-k`` option to specify what test to run.
