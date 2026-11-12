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

   ============================= test session starts ==============================
   platform linux -- Python 3.12.3, pytest-9.2.0, pluggy-1.7.0
   rootdir: /chirouter/src/python/chirouter/tests
   configfile: pytest.ini
   plugins: json-report-1.5.0, metadata-3.1.1
   collected 31 items

   src/python/chirouter/tests/test_2router.py .....                         [ 16%]
   src/python/chirouter/tests/test_3router.py ......                        [ 35%]
   src/python/chirouter/tests/test_basic.py ....................            [100%]

   --------------------------------- JSON report ----------------------------------
   report saved to: tests.json
   ======================== 31 passed in 89.17s (0:01:29) =========================

In the chirouter terminal, you will see the log messages for each test (if you
ran chirouter with ``-v`` or ``-vv``).

To get a score report, run ``./run-grade``:

::

   root@89b17fd037b2:/chirouter# ./run-grade
   chirouter
   =========================================================================
   Category                            Passed / Total       Score  / Points
   -------------------------------------------------------------------------
   Responding to ARP requests          2      / 2           5.00   / 5.00
   ICMP requests to router             6      / 6           15.00  / 15.00
   ARP requests and ARP replies        1      / 1           10.00  / 10.00
   IP forwarding                       3      / 3           15.00  / 15.00
   Handling ARP pending requests       1      / 1           10.00  / 10.00
   Timing out pending ARP requests     2      / 2           5.00   / 5.00
   Basic Topology                      5      / 5           15.00  / 15.00
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
- ``-s``: Do not suppress output from successful tests. By default, pytest only
  shows the output of a test if the test fails; use this option to see the output
  of every test. Note that chirouter's log messages are not part of this output:
  they always appear in the terminal where you are running chirouter (so, if you
  want more detailed log messages, run chirouter with ``-v`` or ``-vv``).

If you are familiar with pytest (the testing framework we use to run the tests),
you can actually pass any parameter accepted by pytest to ``run-tests``.

Running categories of tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to run only a specific category of tests, you can use the
``--chirouter-category`` parameter. For example::

    ./run-tests --chirouter-category RESPONDING_ARP_REQUESTS

To see the exact categories available, run the following
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
