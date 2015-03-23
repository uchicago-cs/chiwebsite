.. _chitcp-fileformat:

The chidb File Format
=====================


chidb is a didactic relational database management system (RDBMS)
designed for teaching how a RDBMS is built internally, from the data
organization in files all the way up to the SQL parser and query
optimizer. The design of chidb is based on SQLite [1]_, with several
simplifying assumptions that make it possible to develop a complete
chidb implementation over the course of a quarter or semester. One of
the key similarities is that chidb uses a single file to store all its
information (database metadata, tables, and indexes). In fact, the chidb
file format is a subset of SQLite, meaning that well-formed chidb files
will also be well-formed SQLite files (the converse, though, is not
necessarily true).

This document describes the format of a chidb database file. We assume a
basic knowledge of RDBMS (a student should know what a table and an
index is) and what a B-Tree is. How the file is created and updated
(e.g., how to add a new entry to a B-Tree) is outside the scope of this
document.

The format of the file is described in a top-down fashion. The document
starts off with an overview of the file format, and then focuses on how
tables are stored in it. Since indexes share many common traits (in
terms of format) with tables, they are discussed at the end of the
document, focusing on the differences with tables. Thus, the document
begins with an overview of how a chidb file is organized, both
physically and logically, in Section [sec:overview], followed by a brief
description of supported datatypes in Section [sec:datatypes] and a
description of the file header in Section [sec:header]. Next, the format
of table pages (Section [sec:tablepages]), table cells
(Section [sec:tablecells]), and database records (Section [sec:records])
is described. The format of indexes is described in
Section [sec:indexes]. Finally, the format of the schema table, a
special table which stores the database schema, is described in
Section [sec:schema].

File format overview
--------------------

The chidb file format is a subset of the SQLite file format [2]_ and,
thus, shares many common traits with it. A chidb file can store any
number of tables, physically stored as a B-Tree, and a table can have
records with any number of fields of different datatypes. Indexes are
also supported, and also stored as B-Trees. However, chidb makes the
following simplifying assumptions:

-  Each table must have an explicit primary key (SQLite allows tables
   without primary keys to be created), and the primary key must be a
   single unsigned 4 byte integer field.

-  Indexes can only be created for unsigned 4-byte integer unique
   fields.

-  Only a subset of the SQLite datatypes are supported.

-  The size of a record cannot exceed the size of a database page (more
   specifically, SQLite overflow pages are not supported). This
   effectively also limits the size of certain datatypes (such as
   strings).

-  The current format is geared towards using the database file only for
   insertion and querying. Although record removal and update are not
   explicitly disallowed, their implementation cannot be done
   efficiently in the current format.

-  A user is assumed to have exclusive access to the database file.

These assumptions were made to simplify the implementation of many
low-level details, so that students can focus on higher-level ideas (but
still requiring a healthy amount of low-level programming). For example,
although supporting database records that span multiple pages is a
necessary feature in production databases, its implementation requires a
fair amount of low-level programming that is algorithmically dull (at
least when compared with algorithms for B-Tree insertion, query
optimization, etc.).

The remainder of this section provides an overview of the logical
organization of a chidb file, followed by its physical organization.
Figure [fig:physlog] summarizes the file organization, and the
relationship between logical and physical organization. Specific details
(e.g., “In what part exactly of the database file should I store a
B-Tree entry?”) are provided in the next sections.

.. figure:: images/physlog.png
   :alt: Physical and logical file organization

   Physical and logical file organization
[fig:physlog]

Logical organization
~~~~~~~~~~~~~~~~~~~~

A chidb file contains the following:

-  A file header.

-  0 or more tables.

-  0 or more indexes.

The ***file header*** contains metadata about the database file, most of
which is relevant to the physical organization of the file. The file
header does *not* contain the database schema (i.e., the specification
of tables and indexes in the database), which is stored in a special
table called the *schema table* (described in Section [sec:schema]).

Each ***table*** in the database file is stored as a B\ :math:`^+`-Tree
(hereafter we will refer to these simply as “table B-Trees”). The
entries of this tree are ***database records*** (a collection of values
corresponding to a row in the table). The key for each entry will be its
primary key. Since a table is a B\ :math:`^+`-tree, the internal nodes
do not contain entries but, rather, are used to navigate the tree.

Each ***index*** in the database file is stored as a B-Tree (hereafter
we will refer to these as “index B-Trees”). Assuming we have a relation
:math:`R(pk,\ldots,ik,\ldots)` where :math:`pk` is the primary key, and
:math:`ik` is the attribute we want to create an index over, each entry
in an index B-Tree will be a :math:`(k_1, k_2)` pair, where :math:`k_1`
is a value of :math:`ik` and :math:`k_2` is the value of the primary key
(:math:`pk`) in the record where :math:`ik=k_1`. More formally, using
relational algebra:

.. math:: k_2=\Pi_{pk} \sigma_{ik=k_1} R

The entries are ordered (and thus keyed) by the value of :math:`k_1`.
Note that an index B-Tree contains as many entries as the table it
indexes. Furthermore, since it is a B-Tree (as opposed to a
B\ :math:`^+`-Tree), both the internal and leaf nodes contain entries
(the internal nodes, additionally, include pointers to child nodes).

Physical organization
~~~~~~~~~~~~~~~~~~~~~

A chidb file is divided into ***pages***\  [3]_ of size Page–Size,
numbered from 1. Each page is used to store a table or index B-Tree
node.

A page contains a ***page header*** with metadata about the page, such
as the type of page (e.g., does it store an internal table node? a leaf
index node?). The space not used by the header is available to store
***cells***, which are used to store B-Tree entries:

Leaf Table cell
    : :math:`\langle \textsc{Key}, \textsc{DB--Record} \rangle`, where
    DB–Record is a database record and Key is its primary key.

Internal Table cell
    : :math:`\langle \textsc{Key}, \textsc{Child--Page} \rangle`, where
    Child–Page is the number of the page containing the entries with
    keys less than or equal to Key.

Leaf Index cell
    : :math:`\langle \textsc{Key--Idx}, \textsc{Key--Pk} \rangle`, where
    Key–Idx and Key–Pk are :math:`k_1` and :math:`k_2`, respectively, as
    defined earlier.

Internal Index cell
    :
    :math:`\langle \textsc{Key--Idx}, \textsc{Key--Pk}, \textsc{Child--Page} \rangle`,
    where Key–Idx and Key–Pk are defined as above, and Child–Page is the
    number of the page containing the entries with keys less than
    Key–Idx.

Page 1 in the database is special, as its first 100 bytes are used by
the file header. Thus, the B-Tree node stored in page 1 can only use
:math:`(\textsc{Page-Size} - 100)` bytes.

Although the exact format of the page, page header, and cells will be
explained later, it is worth explaining one of the values stored in the
page header here. First, note how internal cells store a key and a
Child–Page “pointer” [4]_. However, a B-Tree node must have, by
definition, :math:`n` keys and :math:`n+1` pointers. Using cells,
however, we can only store :math:`n` pointers. Given a node :math:`B`,
an extra pointer is necessary to store the number of the page containing
the node :math:`B'` with keys greater than all the keys in :math:`B`.
This extra pointer is stored in the page header and is called
Right–Page. Figure [fig:rightpage] shows a B-Tree both logically and
physically. Notice how the Right–Page pointer is, essentially, the
“rightmost pointer” in a B-Tree node.

.. figure:: images/rightpage.png
   :alt: Logical and physical view of a table B-Tree.

   Logical and physical view of a table B-Tree.
[fig:rightpage]

Datatypes
---------

chidb uses a limited number of integer and string datatypes, summarized
in Table [tab:datatypes]. All integer types are big-endian. All string
types use lower ASCII encoding (or, equivalently, 1-byte UTF-8). Note
that these are not the types for the database records (which are
described in Section [sec:records]) but, rather, datatypes used
internally in the database file.

+-------------+---------------------------+----------------------------------------+
| **Bytes**   | **Name**                  | **Range**                              |
+=============+===========================+========================================+
|             | Unsigned 1-byte integer   | :math:`0 \leq x \leq 255`              |
+-------------+---------------------------+----------------------------------------+
|             | Unsigned 2-byte integer   | :math:`0 \leq x \leq 65,535`           |
+-------------+---------------------------+----------------------------------------+
|             | Unsigned 4-byte integer   | :math:`0 \leq x \leq 2^{32}-1`         |
+-------------+---------------------------+----------------------------------------+
|             | Signed 1-byte integer     | :math:`-128 \leq x \leq 127`           |
+-------------+---------------------------+----------------------------------------+
|             | Signed 2-byte integer     | :math:`-32768 \leq x \leq 32767`       |
+-------------+---------------------------+----------------------------------------+
|             | Signed 4-byte integer     | :math:`-2^{31} \leq x \leq 2^{31}-1`   |
+-------------+---------------------------+----------------------------------------+
|             | Unsigned 1-byte varint    | :math:`0 \leq x \leq 127`              |
+-------------+---------------------------+----------------------------------------+
|             | Unsigned 2-byte varint    | :math:`0 \leq x \leq 2^{28}-1`         |
+-------------+---------------------------+----------------------------------------+
|             | Nul-terminated string     | # of characters :math:`\leq n`         |
+-------------+---------------------------+----------------------------------------+
|             | Character array           | # of characters :math:`\leq n`         |
+-------------+---------------------------+----------------------------------------+

Table: Datatypes

[tab:datatypes]

is a special integer type that is supported for compatibility with
SQLite. A is a variable-length integer encoding that can store a 64-bit
signed integer using 1-9 bytes, depending on the value of the integer.
To simplify the chidb file format, this datatype is not fully supported.
However, since the type is essential to the SQLite data format, 1-byte
and 4-byte s are supported (hereafter referred to as and ,
respectively). Note that, in chidb, these are *not* variable length
integers; they just follow the format of a variable-length integer
encoding in the particular cases when 1 or 4 bytes are used. Thus,
whenever this document specifies that a is used, that means that exactly
4 bytes (with the format explained below) will be used. There is no need
to determine what the ‘length’ of the integer is.

In a , the most significant bit is always set to ``0``. The remainder of
the byte is used to store an unsigned 7-bit integer:

``0xxxxxxx``

In a , the most significant bit of the three most significant bytes is
always set to ``1`` and the most significant bit of the least
significant byte is always set to ``0``. The remaining bits are used to
store a big-endian unsigned 28-bit integer:

``1xxxxxxx 1xxxxxxx 1xxxxxxx 0xxxxxxx``

File header
-----------

The first 100 bytes of a chidb file contain a header with metadata about
the file. This file header uses the same format as SQLite and, since
many SQLite features are not supported in chidb, most of the header
contains constant values. The layout of the header is shown in
Figure [fig:fileheader]. Note that, at this point, all values except
Page–Size can be safely ignored, but they must all be properly
initialized to the values shown in the table in Figure [fig:fileheader].

.. figure:: images/fileheader.png
   :alt: chidb file header

   chidb file header
+-------------+-----------------------+------------+------------------------------------------------------------------------------------------------------+
| **Bytes**   | **Name**              | **Type**   | **Description**                                                                                      |
+=============+=======================+============+======================================================================================================+
| 16-17       | Page–Size             |            | Size of database page                                                                                |
+-------------+-----------------------+------------+------------------------------------------------------------------------------------------------------+
| 24-27       | File–Change–Counter   |            | Initialized to ``0``. Each time a modification is made to the database, this counter is increased.   |
+-------------+-----------------------+------------+------------------------------------------------------------------------------------------------------+
| 40-43       | Schema–Version        |            | Initialized to ``0``. Each time the database schema is modified, this counter is increased.          |
+-------------+-----------------------+------------+------------------------------------------------------------------------------------------------------+
| 48-51       | Page–Cache–Size       |            | Default pager cache size in bytes. Initialized to ``20000``                                          |
+-------------+-----------------------+------------+------------------------------------------------------------------------------------------------------+
| 60-43       | User–Cookie           |            | Available to the user for read-write access. Initialized to ``0``                                    |
+-------------+-----------------------+------------+------------------------------------------------------------------------------------------------------+

[fig:fileheader]

Table pages
-----------

A table page is composed of four section: the ***page header***, the
***cells***, the ***cell offset array***, and ***free space***. To
understand how they relate to each other, it is important to understand
how cells are laid out in a page. A table page is, to put is simply, a
container of cells. The bytes in a page of size Page–Size are numbered
from 0 to (:math:`\textsc{Page--Size}-1`). Byte 0 is the *top* of the
page, and byte (:math:`\textsc{Page--Size}-1`) is the *bottom* of the
page. Cells are stored in a page from the bottom up. For example, if a
cell of size :math:`c_1` is added to an empty page, that cell would
occupy bytes (:math:`\textsc{Page--Size}-c_1`) through
(:math:`\textsc{Page--Size}-1`). If another cell of size :math:`c_2` is
added, that cell would occupy bytes
(:math:`\textsc{Page--Size}-c_1-c_2`) through
(:math:`\textsc{Page--Size}-c_1-1`). New cells are always added at the
top of the cell area, cells must always be contiguous and there can be
no free space between them. Thus, removing a cell or modifying its
contents requires instantly defragmenting the cells.

The cell offset array is used to keep track of where each cell is
located. The cell offset array is located at the top of the page (after
the page header) and grows from the top down. The :math:`i^\textrm{th}`
entry of the array contains the byte offset of the :math:`i^\textrm{th}`
cell *by increasing key order*. In other words, the cell offset is used
not only to determine the location of each cell, but also their correct
order. Figure [fig:celloffsetarray] shows an example of how the
insertion of a new cells affects the cell offset array. Notice how the
new cell is stored at the top of the cell area, regardless of its key
value. On the other hand, the entry in the cell offset array for the new
cell is inserted in order.

.. figure:: images/cellsexample.png
   :alt: Example of a cell insertion.

   Example of a cell insertion.
[fig:celloffsetarray]

.. figure:: images/page.png
   :alt: Page layout

   Page layout
[fig:page]

The exact layout of the page, summarized in Figure [fig:page] is as
follows:

-  The ***page header*** is located at the top of the page, and contains
   metadata about the page. The exact contents of the page header are
   explained later.

-  The ***cell offset array*** is located immediately after the header.
   Each entry is stored as a . Thus, the length of the cell offset array
   depends on the number of cells in the page.

-  The ***cells*** are located at the end of the page.

-  The space between the cell offset array and the cells is ***free
   space*** for the cell offset array to grow (down) and the cells to
   grow (up).

The layout and contents of the page header are summarized in
Figure [fig:pageheader].

.. figure:: images/pageheader.png
   :alt: Page header

   Page header
+-------------+----------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Bytes**   | **Name**       | **Type**   | **Description**                                                                                                                                                            |
+=============+================+============+============================================================================================================================================================================+
| 0           | Page–Type      |            | The type of page. Valid values are ``0x05`` (internal table page), ``0x0D`` (leaf table page), ``0x02`` (internal index page), and ``0x0A`` (leaf index page)              |
+-------------+----------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 1-2         | Free–Offset    |            | The byte offset at which the free space starts. Note that this must be updated every time the cell offset array grows.                                                     |
+-------------+----------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 3-4         | N–Cells        |            | The number of cells stored in this page.                                                                                                                                   |
+-------------+----------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 5-6         | Cells–Offset   |            | The byte offset at which the cells start. If the page contains no cells, this field contains the value Page–Size. This value must be updated every time a cell is added.   |
+-------------+----------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 8-11        | Right–Page     |            | See Section [sec:physorg] for a description of this value.                                                                                                                 |
+-------------+----------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

[fig:pageheader]

Table cells
-----------

The layout and contents of internal and leaf table cells are summarized
in Figures [fig:tableinternalcell] and [fig:tableleafcell],
respectively.

.. figure:: images/table_internalcell.png
   :alt: Internal cell (table)

   Internal cell (table)
+-------------+--------------+------------+---------------------------------------+
| **Bytes**   | **Name**     | **Type**   | **Description**                       |
+=============+==============+============+=======================================+
| 0-3         | Child–Page   |            | As defined in Section [sec:physorg]   |
+-------------+--------------+------------+---------------------------------------+
| 4-7         | Key          |            | As defined in Section [sec:physorg]   |
+-------------+--------------+------------+---------------------------------------+

[fig:tableinternalcell]

.. figure:: images/table_leafcell.png
   :alt: Leaf cell (table)

   Leaf cell (table)
+-------------+------------------+-----------------------------+---------------------------------------+
| **Bytes**   | **Name**         | **Type**                    | **Description**                       |
+=============+==================+=============================+=======================================+
| 0-3         | DB–Record–Size   |                             | Length of DB–Record in bytes.         |
+-------------+------------------+-----------------------------+---------------------------------------+
| 4-7         | Key              |                             | As defined in Section [sec:physorg]   |
+-------------+------------------+-----------------------------+---------------------------------------+
| 8-…         | DB–Record        | See Section [sec:records]   | As defined in Section [sec:physorg]   |
+-------------+------------------+-----------------------------+---------------------------------------+

[fig:tableleafcell]

Database records
----------------

A database record is used to store the contents of a single table tuple
(or “row”). It can contain a variable number of values of NULL, integer,
or text types. The record is divided into two parts: the record header
and the record data. The record header specifies the types of the values
contained in the record. However, the header does not include schema
information. In other word, a record header may specify that the record
contains an integer, followed by a string, followed by null value,
followed by an integer, but does not store the names of the fields, as
given when the table was created (this information is stored in the
schema table, described in Section [sec:schema]). However, values in a
database record must be stored in the same order as specified in the
``CREATE TABLE`` statement used to create the table.

The format of a database record is shown in Figure [fig:record]. The
header’s first byte is used to store the length in bytes of the header
(including this first byte). This is followed by :math:`n` s or s, where
:math:`n` is the number of values stored in the record. The supported
types are listed in Table [tab:sqltypes]. A is used to specify types
``NULL``, ``BYTE``, ``SMALLINT``, and ``INTEGER``, while a is used to
specify a ``TEXT`` type.

.. figure:: images/record.png
   :alt: Database record format

   Database record format
[fig:record]

| \|c\|c\|c\|p7cm\| **Header value** & **SQL type** & **Internal type
used in record data**
| 0 & ``NULL`` & N/A
| 1 & ``BYTE`` &
| 2 & ``SMALLINT`` &
| 4 & ``INTEGER`` &
| :math:`2\cdot n + 13` & ``TEXT`` &

[tab:sqltypes]

The record data contains the actual values, in the same order as
specified in the header. Note that a value of type ``NULL`` is not
actually stored in the record data (it just has to be specified in the
header). Additionally, the value that corresponds to the table’s primary
key is always stored as a ``NULL`` value (since it is already stored as
the key of the B-Tree cell where the record is stored, repeating it in
the record would be redundant). Figure [fig:recordexample] shows an
example of how a record would be encoded internally.

.. figure:: images/recordexample.png
   :alt: Database record example, for a table created with
   ``CREATE TABLE Courses(Id INTEGER PRIMARY KEY, Name TEXT, Instructor INTEGER, Dept INTEGER)``

   Database record example, for a table created with
   ``CREATE TABLE Courses(Id INTEGER PRIMARY KEY, Name TEXT, Instructor INTEGER, Dept INTEGER)``
[fig:recordexample]

Indexes
-------

An index B-Tree is very similar to a table B-Tree, so most of what was
discussed in the previous sections is applicable to indexes. The main
differences are the following:

-  Page–Type field of the page header must be set to the appropriate
   value (``0x02`` for internal pages and ``0x0A`` for leaf pages)

-  While a table is stored as a B\ :math:`^+`-Tree (records are only
   stored in the leaf nodes), an index is stored as a B-Tree (records
   are stored at all levels). However, an index does not store database
   records but, rather,
   :math:`\langle \textsc{Key--Idx}, \textsc{Key--Pk} \rangle` pairs, as
   defined in Section [sec:physorg]. The format of the index B-Tree
   cells is show in Figure [fig:indexinternalcell] (internal cells) and
   Figure [fig:indexleafcell]. Notice how they both differ only in the
   Child–Page field.

.. figure:: images/index_internalcell.png
   :alt: Internal cell (index)

   Internal cell (index)
+-------------+--------------+------------+---------------------------------------+
| **Bytes**   | **Name**     | **Type**   | **Description**                       |
+=============+==============+============+=======================================+
| 0-3         | Child–Page   |            | As defined in Section [sec:physorg]   |
+-------------+--------------+------------+---------------------------------------+
| 8-11        | Key–Idx      |            | As defined in Section [sec:physorg]   |
+-------------+--------------+------------+---------------------------------------+
| 12-15       | Key–Pk       |            | As defined in Section [sec:physorg]   |
+-------------+--------------+------------+---------------------------------------+

[fig:indexinternalcell]

.. figure:: images/index_leafcell.png
   :alt: Leaf cell (index)

   Leaf cell (index)
+-------------+------------+------------+---------------------------------------+
| **Bytes**   | **Name**   | **Type**   | **Description**                       |
+=============+============+============+=======================================+
| 4-7         | Key–Idx    |            | As defined in Section [sec:physorg]   |
+-------------+------------+------------+---------------------------------------+
| 8-11        | Key–Pk     |            | As defined in Section [sec:physorg]   |
+-------------+------------+------------+---------------------------------------+

[fig:indexleafcell]

The schema table
----------------

Up to this point, this document has covered how to store one or more
tables and indexes in a chidb file. However, there is no way of knowing
how many tables/indexes are stored in the file, what their schema is,
and how the indexes relate to the tables. This information is stored in
a special *schema table*. More specifically, a chidb file will always
contain at least one table B-Tree, rooted in page 1, which will be used
to store information on the database schema. The schema table contains
one record for each table and index in the database.
Table [tab:schemafields] lists the values that must be stored in each
record.

+---------------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
| **Type**      | **Name**                | **Description**                                                                                                                                       |
+===============+=========================+=======================================================================================================================================================+
| ``TEXT``      | Schema item type        | ``table`` or ``index``                                                                                                                                |
+---------------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``TEXT``      | Schema item name        | Name of the table or index as specified in the ``CREATE TABLE`` or ``CREATE INDEX`` statement.                                                        |
+---------------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``TEXT``      | Associated table name   | For tables, this field is the same as the schema item name (the name of the table). For indexes, this value contains the name of the indexed table.   |
+---------------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``INTEGER``   | Root page               | Database page where the root node of the B-Tree is stored.                                                                                            |
+---------------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
| ``TEXT``      | SQL statement           | The SQL statement used to create the table or index.                                                                                                  |
+---------------+-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+

Table: Fields of a schema table record

[tab:schemafields]

+------------+---------------+--------------------+-----------------+-------------------------------------------------------------------------------------------------+
| **Type**   | **Name**      | **Assoc. Table**   | **Root Page**   | **SQL**                                                                                         |
+============+===============+====================+=================+=================================================================================================+
| table      | Courses       | Courses            | 2               | ``CREATE TABLE Courses(Id INTEGER PRIMARY KEY, Name TEXT, Instructor INTEGER, Dept INTEGER)``   |
+------------+---------------+--------------------+-----------------+-------------------------------------------------------------------------------------------------+
| table      | Instructors   | Instructors        | 3               | ``CREATE TABLE Instructors(Id INTEGER PRIMARY KEY, Name TEXT)``                                 |
+------------+---------------+--------------------+-----------------+-------------------------------------------------------------------------------------------------+
| index      | idxInstr      | Courses            | 6               | ``CREATE INDEX idxInst ON Courses(Instructor)``                                                 |
+------------+---------------+--------------------+-----------------+-------------------------------------------------------------------------------------------------+

Table: Example of a schema table

[tab:schemaexample]

.. [1]
   http://www.sqlite.org/

.. [2]
   http://www.sqlite.org/fileformat.html

.. [3]
   Pages are sometimes referred to as ’blocks’ in the literature. They
   are the units of transfer between secondary storage and memory

.. [4]
   In the literature, B-Tree nodes are shown as being linked with
   pointers. It is worth emphasizing that, when storing a B-Tree in a
   file, this “pointer” is simply the number of the page where the
   referenced node can be found
