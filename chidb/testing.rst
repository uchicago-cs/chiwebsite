.. _chidb-testing:

Testing your Implementation
===========================

We provide a number of automated tests and tools that you can use to
test your implementation.

Automated tests
---------------

You can run the chidb automated tests by running this::

    make check


Running tests selectively
-------------------------

Running through the entire test suite can be cumbersome if you're trying to debug only
a specific issue. You can run individual groups
of tests like this:

* Assignment 1::

    CK_RUN_CASE="Step 1a: Opening an existing chidb file" make check
    CK_RUN_CASE="Step 1b: Opening a new chidb file" make check
    CK_RUN_CASE="Step 2: Loading a B-Tree node from the file" make check
    CK_RUN_CASE="Step 3: Creating and writing a B-Tree node to disk" make check
    CK_RUN_CASE="Step 4: Manipulating B-Tree cells" make check
    CK_RUN_CASE="Step 5: Finding a value in a B-Tree" make check
    CK_RUN_CASE="Step 6: Insertion into a leaf without splitting" make check
    CK_RUN_CASE="Step 7: Insertion with splitting" make check
    CK_RUN_CASE="Step 8: Supporting index B-Trees" make check


Sample chidb files
------------------

TODO


Running DBM programs
--------------------

TODO


The chidb shell
---------------

TODO

