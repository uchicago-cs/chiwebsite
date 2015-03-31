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


Sample "string" B-Tree files
----------------------------

We provide a number of files that can be used to debug your B-Tree code. The "string" B-Tree files are chidb files with a single B-Tree, always rooted in page 1, where the contents of each leaf cell is just a nul-terminated string, instead of a database record. Everything else follows the chidb file format specification (file header, page headers, etc.). Although they are not strictly well-formed chidb files, they are easier to read with a binary editor. Note that, regardless of the string length, each string occupies 128 bytes in the cell.

``tests/files/databases/strings-1page.sdb``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This file has a single page which contains a single B-Tree.

::

    Leaf node (page 1)
        1 ->       foo1
        2 ->       foo2
       10 ->      foo10
       35 ->      foo35
       37 ->      foo37
       42 ->      foo42

``tests/files/databases/strings-1btree.sdb``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This file contains a single B-Tree with height 2. The root node is located in page 1,
and its child nodes are located in pages 2, 3, 4, and 5.

::

    Internal node (page 1)
    Printing Keys <= 7
    Leaf node (page 4)
        1 ->       foo1
        2 ->       foo2
        3 ->       foo3
        7 ->       foo7
    Printing Keys <= 35
    Leaf node (page 3)
       10 ->      foo10
       15 ->      foo15
       20 ->      foo20
       35 ->      foo35
    Printing Keys <= 1000
    Leaf node (page 5)
       37 ->      foo37
       42 ->      foo42
      127 ->     foo127
     1000 ->    foo1000
    Printing Keys > 1000
    Leaf node (page 2)
     2000 ->    foo2000
     3000 ->    foo3000
     4000 ->    foo4000
     5000 ->    foo5000

Sample chidb files
------------------

We also provide several well-formed chidb files, which can also be used to test your B-Tree code, but are better suited for Assignments 2 and 3. Unlike the "string" databases, each leaf cell contains a database record, and the database includes a schema table in page 1. All these files can also be opened in SQLite.


``tests/files/databases/1table-1page.cdb``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This file contains a single table occupying a single page (page 2).

::

    Schema table:
    Leaf node (page 1)
    <     1 >| table | courses | courses | 2 | CREATE TABLE courses(code INTEGER PRIMARY KEY, name TEXT, prof BYTE, dept INTEGER) |

    Table:
    Leaf node (page 2)
    < 21000 >|| Programming Languages | 75 | 89 |
    < 23500 >|| Databases || 42 |
    < 27500 >|| Operating Systems || 89 |


``tests/files/databases/1table-1index-1pageeach.cdb``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This file contains a single table and an index on that table. The table occupies a single page (page 2) and the index occupies a single page (page 3).

::

    Schema table:
    Leaf node (page 1)
    <     1 >| table | numbers | numbers | 2 | CREATE TABLE numbers(code INTEGER PRIMARY KEY, textcode TEXT, altcode INTEGER) |
    <     2 >| index | idxNumbers | numbers | 3 | CREATE INDEX idxNumbers ON numbers(altcode) |

    Table:
    Leaf node (page 2)
    <   100 >|| foo100 | 20100 |
    <   200 >|| foo200 | 20200 |
    <   300 >|| foo300 | 20300 |

    Index:
    Leaf node (page 3)
         20100 ->        100
         20200 ->        200
         20300 ->        300


``tests/files/databases/1table-largebtree.cdb``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a file with the same table and index as the previous file, but where the table B-Tree has height 3. The total size of the file is 202 pages.
