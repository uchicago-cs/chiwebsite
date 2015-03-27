.. _chidb-assignment-btrees:

Assignment I: B-Trees
=====================

In this first assignment, you will be implementing a series of functions
for manipulating B-Trees in chidb. This assignment is divided into the following
steps:

#. Opening a chidb file

#. Loading a B-Tree node from the file

#. Creating and writing a B-Tree node to disk

#. Manipulating B-Tree cells

#. Finding a value in a B-Tree

#. Insertion into a leaf without splitting

#. Insertion with splitting

#. Supporting index B-Trees

All of these steps can be developed independently (the only exception is
step 8, which is a cross-cutting feature). Nonetheless, testing a step
will usually require that some of the previous steps be implemented
(e.g., you can’t find a value in a B-Tree if you can’t open the file
itself).

Before you get started
----------------------

Before you start working on this assignment, make sure read 
:ref:`chidb-fileformat`. You are not expected to understand the entire document at
first, but you should at least get a general feel for how a chidb file
is organized.

Most of your work will be done on the files ``src/libchidb/btree.[hc]``.
The header file contains declarations of functions you will have to
implement, and which are referred to in the rest of the document. The
specification of what the functions must do is included in the source as
comments.

..
    TODO: References to building and testing

Step 1: Opening a chidb file
----------------------------

Implement the following functions:

.. code-block:: c

    int chidb_Btree_open(const char *filename, chidb *db, BTree **bt)
    int chidb_Btree_close(BTree *bt);

Take into account that the ``chidb_Btree_open`` function can open an
existing file, but can also create an empty database file if given the
name of a file that does not exist. The latter functionality will not be
possible until Step 3 is completed.

Step 2: Loading a B-Tree node from the file
-------------------------------------------

Implement the following functions:

.. code-block:: c

    int chidb_Btree_getNodeByPage(BTree *bt, npage_t npage, BTreeNode **node);
    int chidb_Btree_freeMemNode(BTree *bt, BTreeNode *btn);

Step 3: Creating and writing a B-Tree node to disk
--------------------------------------------------

Implement the following function:

.. code-block:: c

    int chidb_Btree_newNode(BTree *bt, npage_t *npage, uint8_t type);
    int chidb_Btree_initEmptyNode(BTree *bt, npage_t npage, uint8_t type);
    int chidb_Btree_writeNode(BTree *bt, BTreeNode *node);

Step 4: Manipulating B-Tree cells
---------------------------------

Implement the following functions:

.. code-block:: c

    int chidb_Btree_getCell(BTreeNode *btn, ncell_t ncell, BTreeCell *cell);
    int chidb_Btree_insertCell(BTreeNode *btn, ncell_t ncell, BTreeCell *cell);

Take into account that, once you’ve implemented ``chidb_Btree_getCell``
(which is the simpler of the two), you will be able to implement
``chidb_Btree_find`` or use the provided ``chidb_Btree_print``. At that
point, you will be able to open example database files (available at the
chidb website) and verify that you can correctly print out their
contents or search for specific values.

Step 5: Finding a value in a B-Tree
-----------------------------------

Implement the following function:

.. code-block:: c

    int chidb_Btree_find(BTree *bt, npage_t nroot, key_t key, uint8_t **data, uint16_t *size);

Step 6: Insertion into a leaf without splitting
-----------------------------------------------

Implement the following functions:

.. code-block:: c

    int chidb_Btree_insertInTable(BTree *bt, npage_t nroot, 
                                  key_t key, uint8_t *data, uint16_t size);
    int chidb_Btree_insert(BTree *bt, npage_t nroot, BTreeCell *btc);
    int chidb_Btree_insertNonFull(BTree *bt, npage_t npage, BTreeCell *btc);

Take into account that, at this point, ``chidb_Btree_insert`` will be
little more than a call to ``chidb_Btree_insertNonFull``. Also, even if
at this point you are only inserting in leaf nodes, that doesn’t mean
that your implementation shouldn’t work on a database file that does
have internal nodes. So, ``chidb_Btree_insertNonFull`` should still
traverse the tree in search of the leaf node to insert the cell in (but
assuming that splitting will not be necessary)

Since the chidb file format is a subset of the SQLite format, once this
step is completed you will be able to create a chidb file and open it in
SQLite, as long as you include a valid schema table in the file.

Step 7: Insertion with splitting
--------------------------------

Implement the following function:

.. code-block:: c

    int chidb_Btree_split(BTree *bt, npage_t npage_parent, npage_t npage_child, 
                                     ncell_t parent_cell, npage_t *npage_child2);

Note that you will also have to modify ``chidb_Btree_insert`` and
``chidb_Btree_insertNonFull`` to split nodes when necessary.

Step 8: Supporting index B-Trees
--------------------------------

Supporting index B-Trees affects almost all of the previous functions.
As such, this step can either be done from the very beginning (at the
cost of complicating the implementation of the previous functions), or
added at the end (simplifying the implementation of the previous
functions, but adding more work at the end of this assignment).

Besides modifying the previous functions, you will also have to
implement the following function:

.. code-block:: c

    int chidb_Btree_insertInIndex(BTree *bt, npage_t nroot, key_t keyIdx, key_t keyPk);


