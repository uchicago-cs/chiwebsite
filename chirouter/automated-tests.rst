.. _chirouter-automated-tests:

Automated Tests
===============

To run the tests, you will need two terminals: one to run chirouter, and
another to run the Docker container.

On the chirouter terminal, run chirouter::

   ./chirouter

(you can also add ``-v`` or ``-vv`` to print more log messages)

In the docker terminal, run ``./run-docker`` with no parameters to get a
root shell on the Docker container::

   $ ./run-docker
   root@e37390d6efd7:/chirouter#

Then, inside the root shell, run ``./run-tests``. This will run all the
tests:

::

   ================================ test session starts ================================
   platform linux -- Python 3.10.12, pytest-8.2.0, pluggy-1.5.0
   rootdir: /chirouter/src/python/chirouter/tests
   configfile: pytest.ini
   plugins: json-0.4.0
   collected 24 items

   src/python/chirouter/tests/test_2router.py .....                              [ 20%]
   src/python/chirouter/tests/test_3router.py ......                             [ 45%]
   src/python/chirouter/tests/test_basic.py .............                        [100%]

   ------------------- generated json report: /chirouter/tests.json --------------------
   =========================== 24 passed in 98.03s (0:01:38) ===========================

In the chirouter terminal, you will see the log messages for each test.

To get a score report, run ``./run-grade``:

::

   root@89b17fd037b2:/chirouter# ./run-grade
   chirouter
   =========================================================================
   Category                            Passed / Total       Score  / Points
   -------------------------------------------------------------------------
   Responding to ARP requests          1      / 1           5.00   / 5.00
   ICMP requests to router             3      / 3           15.00  / 15.00
   ARP requests and ARP replies        1      / 1           10.00  / 10.00
   IP forwarding                       2      / 2           15.00  / 15.00
   Handling ARP pending requests       1      / 1           10.00  / 10.00
   Timing out pending ARP requests     1      / 1           5.00   / 5.00
   Basic Topology                      4      / 4           15.00  / 15.00
   The Two Router Topology             5      / 5           15.00  / 15.00
   The Three Router Topology           6      / 6           10.00  / 10.00
   -------------------------------------------------------------------------
                                                    TOTAL = 100.00 / 100
   =========================================================================


Test parameters
---------------

You can have greater control on how the tests are run by passing certain
parameters to ``run-tests``. More specifically, you can use the
following parameters:

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

If you are familiar with pytest (the testing framework we use to run the tests),
you can actually pass any parameter accepted by pytest to ``run-tests``.

Running categories of tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to run only a specific category of tests, you can use the
``--chirouter-category`` parameter. For example::

    ./run-tests --chirouter-category RESPONDING_ARP_REQUESTS

To see the exact categories available in each assignment, run the following
inside your ``build/`` directory::

    make test-categories

Running individual tests
~~~~~~~~~~~~~~~~~~~~~~~~

If you want to focus on debugging an individual test that is failing, you can
run a single test by using the ``-k`` parameter::

   ./run-tests -k test_ping_router
   
The name of each failed test can be found after the ``FAILURES`` line in the output
from the tests. For example::

   ===================================== FAILURES =====================================
   _____________________  TestTraceroute.test_traceroute_router _______________________

Debugging a test with a debugger
--------------------------------

If you want to debug a test with a debugger, such as gdb, you can run the tests as described above, but using a debugger to run the ``chirouter`` executable.

If using gdb, you would have to run chirouter like this::

    gdb --args ./chirouter -vv

Don't forget to then use gdb's ``run`` command to actually run chirouter.

Similarly, if using Valgrind, you would have to run chirouter like this::

    valgrind ./chirouter -vv

In practice, it only makes sense to debug one test at a time, so you must
make sure to use the ``-k`` parameter when running the tests::

    ./run-tests -k test_ping_router
