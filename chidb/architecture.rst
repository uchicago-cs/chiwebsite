.. _chidb-architecture:

The chidb Architecture
======================

This section describes the chidb architecture, summarized in the following figure:

.. figure:: images/arch_overview.png
   :alt: chidb architecture

Backend
    Contains the **B-Tree module** and the **Pager module**. The
    B-Tree module is responsible for managing a collection of file-based
    B-Trees, using the chidb file format. However, the B-Tree module
    does not include any I/O code. All I/O is delegated to the Pager,
    which provides a page-by-page access to a chidb file. The Pager may
    include a page cache to optimize disk access.

    The specifications of the chidb file format can be found in
    :ref:`chidb-fileformat`

Core
    Contains the **chidb API**, a **SQL compiler**, and a
    **database machine** (or DBM). The API is the interface that other
    applications must go through to use a chidb file, and allows client
    software to open a chidb file, execute SQL statements on that file,
    and close the file. When a SQL statement is submitted, it is
    processed by the SQL compiler. The compiler itself is divided into
    two modules: a SQL parser, which produces a convenient in-memory
    representation of a SQL query, and the code generator and optimizer,
    which generates code for the database machine. The database machine
    is a virtual machine specifically designed to operate on chidb
    files, and includes instructions such as "Create a new table", "Find
    a record with key :math:`k`", etc.

Accessories
    Includes a **utilities** modules, with miscellaneous code that are
    used across all modules, and **testing** code.

chidb API
---------

The chidb API comprises a set of functions that allows client software
to access and manipulate chidb files, including executing SQL statements
on them. Unless otherwise noted, each API function returns one of the
return codes listed in the following table. This table lists every
possible return code; the description of each API function notes what
return codes can be returned by that specific function.

.. cssclass:: table-bordered

+-----------------------+------------------+--------------------------------------------------------+
| **Name**              | **Integer code** | **Description**                                        |
+=======================+==================+========================================================+
| ``CHIDB_OK``          | 0                | Succesful result                                       |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_EINVALIDSQL`` | 1                | Invalid SQL                                            |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_ENOMEM``      | 2                | Could not allocate memory                              |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_ECANTOPEN``   | 3                | Unable to open the database file                       |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_ECORRUPT``    | 4                | The database file is not well formed                   |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_ECONSTRAINT`` | 5                | SQL statement failed because of a constraint violation |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_EMISMATCH``   | 6                | Data type mismatch                                     |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_EIO``         | 7                | An I/O error has occurred when accessing the file      |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_EMISUSE``     | 8                | API used incorrectly                                   |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_ROW``         | 100              | ``chidb_step()`` has another row ready                 |
+-----------------------+------------------+--------------------------------------------------------+
| ``CHIDB_DONE``        | 101              | ``chidb_step()`` has finished executing                |
+-----------------------+------------------+--------------------------------------------------------+


``chidb_open``
~~~~~~~~~~~~~~

The ``chidb_open`` function is used to open a chidb file. Its signature
is the following:

.. code-block:: c

    int chidb_open(
      const char* file, 
      chidb**     db
    );

``file`` is the filename of the chidb file to open. If the file does not
exist, it will be created. ``db`` is used to return a pointer to a
``chidb`` variable. The ``chidb`` type is an *opaque* type representing
a chidb database. In other words, an API user should not be concerned
with what is contained in a ``chidb`` variable, and should simply use it
as a representation of a chidb database to pass along to other API
functions.

The return value of the function can be ``CHIDB_OK``, ``CHIDB_ENOMEM``,
``CHIDB_ECANTOPEN``, ``CHIDB_ECORRUPT``, or ``CHIDB_EIO``.

``chidb_close``
~~~~~~~~~~~~~~~

The ``chidb_close`` function is used to close a chidb file. Its
signature is the following:

.. code-block:: c

    int chidb_close(chidb *db); 

``db`` is the database to close.

The return value of the function can be ``CHIDB_OK`` or
``CHIDB_EMISUSE`` (if called on a database that is already closed).

``int chidb_prepare``
~~~~~~~~~~~~~~~~~~~~~

The ``chidb_prepare`` function is used to prepare a SQL statement for
execution. Internally, this will require compiling the SQL statement
(but not running it yet). The function’s signature is:

.. code-block:: c

    int chidb_prepare(
      chidb*       db, 
      const char*  sql, 
      chidb_stmt** stmt
    );

``db`` is the database on which to run the SQL statement. ``sql`` is the
SQL statement itself. ``stmt`` is used to return a pointer to a
``chidb_stmt`` variable. The ``chidb_stmt`` type is an *opaque* type
representing a SQL statement.

The return value of the function can be ``CHIDB_OK``,
``CHIDB_EINVALIDSQL``, ``CHIDB_ENOMEM``.

``int chidb_step``
~~~~~~~~~~~~~~~~~~

The ``chidb_step`` function runs a prepared SQL statement until a result
row is available (or just runs the SQL statement to completion if it is
not meant to produce a result row, such as an INSERT statement). Its
signature is:

.. code-block:: c

    int chidb_step(chidb_stmt *stmt);

``stmt`` is the SQL statement to run.

If the statement is a SELECT statement, ``chidb_step`` returns
``CHIDB_ROW`` each time a result row is produced. The values of the
result row can be accessed using the column access functions described
below. Thus, ``chidb_step`` has to be called repeatedly to access all
the rows returned by the query. Once there are no more rows left, or if
the statement is not meant to produce any results, then ``CHIDB_DONE``
is returned (note that this function does not return ``CHIDB_OK``).

The function can also return ``CHIDB_ECONSTRAINT``, ``CHIDB_EMISMATCH``,
``CHIDB_EMISUSE`` (if called on a finalized SQL statement), or
``CHIDB_EIO``.

``int chidb_finalize``
~~~~~~~~~~~~~~~~~~~~~~

The ``chidb_finalize`` function finalizes a SQL statement, freeing all
resources associated with it.

.. code-block:: c

    int chidb_finalize(chidb_stmt *stmt);

``stmt`` is the SQL statement to finalize.

The return value of the function can be ``CHIDB_OK`` or
``CHIDB_EMISUSE`` (if called on a statement that is already finalized).

Column access functions
~~~~~~~~~~~~~~~~~~~~~~~

Once a SQL statement has been prepared, the following three functions
can be used to obtain information on the columns of the rows that will
be returned by the statement:

.. code-block:: c

    int chidb_column_count(chidb_stmt *stmt);

    int chidb_column_type(
      chidb_stmt* stmt, 
      int         col
    );

    const char *chidb_column_name(
      chidb_stmt* stmt, 
      int         col
    );

In all these functions, the ``stmt`` parameter is the prepared SQL
statement.

``chidb_column_count`` returns the number of columns in the result rows.
If the SQL statement is not meant to produce any results (such as an
INSERT statement), then 0 is returned.

``chidb_column_type`` returns the type of column ``col`` (columns are
numbered from 0). The supported types are summarized in the folllowing
table.

.. cssclass:: table-bordered

+-----------------------------+--------------+-----------------------+
| **Header Value**            | **SQL Type** | **Description**       |
+=============================+==============+=======================+
| 0                           | ``NULL``     | Null value            |
+-----------------------------+--------------+-----------------------+
| 1                           | ``BYTE``     | 1-byte signed integer |
+-----------------------------+--------------+-----------------------+
| 2                           | ``SMALLINT`` | 2-byte signed integer |
+-----------------------------+--------------+-----------------------+
| 4                           | ``INTEGER``  | 4-byte signed integer |
+-----------------------------+--------------+-----------------------+
| :math:`2\cdot\texttt{n}+13` | ``TEXT``     | Character string      |
+-----------------------------+--------------+-----------------------+


``chidb_column_name`` returns a pointer to a null-terminated string
containing the name of column ``col``. The API client does not have to
``free()`` the returned string. It is the API function’s responsibility
to allocate and free the memory for this string.


If ``chidb_step`` returns ``CHIDB_ROW``, the following two functions can
be used to access the contents of each column:

.. code-block:: c

    int chidb_column_int(
      chidb_stmt* stmt, 
      int         col
    );

    const char *chidb_column_text(
      chidb_stmt* stmt, 
      int         col
    );

In all these functions, the ``stmt`` parameter is the SQL statement.

``chidb_column_int`` returns the integer value in column ``col`` of the
row. The column must be of type ``BYTE``, ``SMALLINT``, or ``INTEGER``.

``chidb_column_text`` returns a pointer to a null-terminated string
containing the value in column ``col`` of the row. The API client does
not have to ``free()`` the returned string. It is the API function’s
responsibility to allocate and free the memory for this string.

Note that none of these functions return error codes. Calling the column
access functions on an unprepared statement, or accessing column values
on a statement that has not produced a result row, will produce
unexpected behaviour.

Supported SQL
-------------

chidb supports a very limited subset of the SQL language. However, this
subset is still sufficiently featureful to run basic queries and perform
interesting query optimizations. This subset has the following main constraints:

#. The field list in a SELECT statement can only be a list of columns in
   the form “[table.]column” or “\*”. Subqueries, arithmetic
   expressions, and aggregate functions are not supported.

#. The FROM clause can only be a list of table names. The AS operator is
   not supported.

#. The WHERE clause can only be a list of AND’ed conditions (e.g.,
   *cond1* AND *cond2* …AND *condN*). Each condition can only be of the
   form "column operator value" or "column operator column". Only the
   :math:`=`, :math:`<>`, :math:`>`, :math:`<`, :math:`>=`, :math:`<=`,
   IS NULL, and IS NOT NULL operators are supported.

#. The VALUES clause of an INSERT operator must always provide literal
   integer or string values. Subqueries or arithmetic operations are not
   supported.

#. In accordance with the chidb file format, CREATE TABLE can only
   create tables with BYTE, SMALLINT, INTEGER, or TEXT columns. The
   primary key can only be an INTEGER field.

#. In accordance with the chidb file format, CREATE INDEX can only
   create indexes on a single integer field.

.. _chidb-dbm:

Database Machine
----------------

The database machine (or DBM) is a computing machine specifically
designed to operate on chidb files, and includes instructions such as
"Create a new table", "Find a record with key :math:`k`", etc. The DBM
architecture is summarized in the following figure:

.. figure:: images/dbm.png
   :alt: chidb Database Machine

The DBM program
    A DBM program is composed of one or more DBM instructions. An
    instruction contains an operation code and up to four operands: P1,
    P2, P3, and P4. P1 through P3 are signed 32-bit integers, and P4 is
    a pointer to a null-terminated string. All the DBM instructions are
    described below. Instructions in the DBM program are
    numbered from 0.

Program counter
    Keeps track of what instruction is currently being executed. Certain
    instructions can directly modify the program counter to jump to a
    specific instruction in the program.

Registers
    The DBM has an unlimited number of registers. A register can contain
    a 32-bit signed integer, a pointer to a null-terminated string or to
    raw binary data, or a NULL value. Registers are numbered from 0.

Cursors
    A cursor is a pointer to a specific entry in a B-Tree. Cursors must
    be able to move to the next or previous entry in a B-Tree in
    amortized :math:`O(1)` time. Hint: this will require an auxiliary
    data structure of size :math:`O(\log(n))`.

A DBM starts executing a program on the :math:`0^{\textrm{th}}`
instruction, and executes subsequent instructions sequentially until a
``Halt`` instruction is encountered, or until the program counter
advances past the end of the program (which is equivalent to a ``Halt``
instruction with all its parameters set to 0). Note that it is also
possible for individual instructions to fail, resulting in a premature
termination of the program.


Register Manipulation Instructions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. cssclass:: table-bordered

+-------------+----------------------+----------------------+----+--------------------+-------------------------------------------------+
| Instruction | P1                   | P2                   | P3 | P4                 | Description                                     |
+=============+======================+======================+====+====================+=================================================+
| ``Integer`` | An integer :math:`i` | A register :math:`r` |    |                    | Store :math:`i` in :math:`r`.                   |
+-------------+----------------------+----------------------+----+--------------------+-------------------------------------------------+
| ``String``  | A length :math:`l`   | A register :math:`r` |    | A string :math:`s` | Store :math:`s` (with length :math:`l`) in      |
|             |                      |                      |    |                    | :math:`r`.                                      |
+-------------+----------------------+----------------------+----+--------------------+-------------------------------------------------+
| ``Null``    |                      | A register :math:`r` |    |                    | Store a null value in :math:`r`.                |
+-------------+----------------------+----------------------+----+--------------------+-------------------------------------------------+
| ``SCopy``   | A register           | A register           |    | A string :math:`s` | Make a shallow copy of the contents of          |
|             | :math:`r_1`          | :math:`r_2`          |    |                    | :math:`r_1` into :math:`r_2`. i.e., :math:`r_2` |
|             |                      |                      |    |                    | must be left *pointing* to the same value as    |
|             |                      |                      |    |                    | :math:`r_1`.                                    |
+-------------+----------------------+----------------------+----+--------------------+-------------------------------------------------+



Control Flow Instructions
~~~~~~~~~~~~~~~~~~~~~~~~~

.. cssclass:: table-bordered

+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+
| Instruction | P1                                                                                                               | P2             | P3          | P4               | Description                                      |
+=============+==================================================================================================================+================+=============+==================+==================================================+
| ``Eq``      | A register                                                                                                       | A jump address | A register  |                  | If the contents of :math:`r_1` are equal to      |
|             | :math:`r_1`                                                                                                      | :math:`j`      | :math:`r_2` |                  | the contents of :math:`r_2`, jump to :math:`j`.  |
|             |                                                                                                                  |                |             |                  | Otherwise, do nothing. This instruction assumes  |
|             |                                                                                                                  |                |             |                  | that the types of the contents of both registers |
|             |                                                                                                                  |                |             |                  | are the same. The behaviour when either of the   |
|             |                                                                                                                  |                |             |                  | registers is NULL is undefined.                  |
+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+
| ``Ne``      | Same as ``Eq``, but testing for inequality of values                                                             |                |             |                  |                                                  |
+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+
| ``Lt``      | Same as ``Eq``, but testing for the value in :math:`r_2` being less than the value in :math:`r_1`                |                |             |                  |                                                  |
+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+
| ``Le``      | Same as ``Eq``, but testing for the value in :math:`r_2` being less than or equal to the value in :math:`r_1`    |                |             |                  |                                                  |
+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+
| ``Gt``      | Same as ``Eq``, but testing for the value in :math:`r_2` being greater than the value in :math:`r_1`             |                |             |                  |                                                  |
+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+
| ``Ge``      | Same as ``Eq``, but testing for the value in :math:`r_2` being greater than or equal to the value in :math:`r_1` |                |             |                  |                                                  |
+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+
| ``Halt``    | An integer                                                                                                       |                |             | An error message | Halt execution of the database machine and       |
|             | :math:`n`                                                                                                        |                |             | :math:`s`        | return error code :math:`n`. If :math:`n\neq 0`, |
|             |                                                                                                                  |                |             |                  | set the machine’s error message to :math:`s`.    |
+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+
| ``Noop``    |                                                                                                                  |                |             |                  | Does nothing.                                    |
+-------------+------------------------------------------------------------------------------------------------------------------+----------------+-------------+------------------+--------------------------------------------------+

Note: Unless instructed otherwise, comparison of binary registers is not necessary. If instructed to implement it, then
comparisons must be made byte by byte. Two binary blobs are equal if and only if they have the same length and contain 
the exact same bytes. If two binary blobs have different lengths, order is determined by the common bytes between the two blobs.
If the common bytes are equal, then the blob with the fewer bytes is considered to be less than the blob with more bytes. 


Database Opening and Closing Instructions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. cssclass:: table-bordered

+---------------+----------------------------------------------------------------+-----------------------+----------------------+----+-------------------------------------------------+
| Instruction   | P1                                                             | P2                    | P3                   | P4 | Description                                     |
+===============+================================================================+=======================+======================+====+=================================================+
| ``OpenRead``  | A cursor :math:`c`                                             | A register :math:`r`. | The number of        |    | Opens the B-Tree rooted at the page :math:`n`   |
|               |                                                                | The register must     | columns in the table |    | for read-only access and stores a cursor for it |
|               |                                                                | contain a page number | (0 if opening an     |    | in :math:`c`                                    |
|               |                                                                | :math:`n`             | index)               |    |                                                 |
+---------------+----------------------------------------------------------------+-----------------------+----------------------+----+-------------------------------------------------+
| ``OpenWrite`` | Same as ``OpenRead`` but opening the B-Tree in read/write mode |                       |                      |    |                                                 |
+---------------+----------------------------------------------------------------+-----------------------+----------------------+----+-------------------------------------------------+
| ``Close``     | A cursor :math:`c`                                             |                       |                      |    | Closes cursor :math:`c` and frees up any        |
|               |                                                                |                       |                      |    | resources associated with it.                   |
+---------------+----------------------------------------------------------------+-----------------------+----------------------+----+-------------------------------------------------+


Cursor Manipulation Instructions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. cssclass:: table-bordered

+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| Instruction | P1                                                                                                                 | P2             | P3                    | P4 | Description                                       |
+=============+====================================================================================================================+================+=======================+====+===================================================+
| ``Rewind``  | A cursor :math:`c`                                                                                                 | A jump address |                       |    | Makes cursor :math:`c` point to the first entry   |
|             |                                                                                                                    | :math:`j`      |                       |    | in the B-Tree. If the B-Tree is empty, then jump  |
|             |                                                                                                                    |                |                       |    | to :math:`j`.                                     |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``Next``    | A cursor :math:`c`                                                                                                 | A jump address |                       |    | Advance cursor :math:`c` to the next entry in     |
|             |                                                                                                                    | :math:`j`      |                       |    | the B-Tree and jump to :math:`j`. If there are    |
|             |                                                                                                                    |                |                       |    | no more entries (if cursor :math:`c` was          |
|             |                                                                                                                    |                |                       |    | pointing at the last entry in the B-Tree),        |
|             |                                                                                                                    |                |                       |    | do nothing.                                       |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``Prev``    | Same as ``Next`` but moving the cursor to the previous entry                                                       |                |                       |    |                                                   |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``Seek``    | A cursor :math:`c`                                                                                                 | A jump address | A register :math:`r`. |    | Move cursor :math:`c` to point to the entry       |
|             |                                                                                                                    | :math:`j`      | The register must     |    | with key equal to :math:`k`. If the cursor points |
|             |                                                                                                                    |                | contain a key         |    | to an index B-Tree, the key that must match is    |
|             |                                                                                                                    |                | :math:`k`             |    | :math:`IdxKey` in the :math:`(IdxKey,PKey)` pair. |
|             |                                                                                                                    |                |                       |    | If the B-Tree doesn’t contain :math:`k`, jump to  |
|             |                                                                                                                    |                |                       |    | :math:`j`.                                        |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``SeekGt``  | Same as ``Seek``, but moving the cursor to the first entry such that its key is greater than :math:`k`.            |                |                       |    |                                                   |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``SeekGe``  | Same as ``Seek``, but moving the cursor to the first entry such that its key is greater than or equal to :math:`k` |                |                       |    |                                                   |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``SeekLt``  | Same as ``Seek``, but moving the cursor to the entry with the largest key less than :math:`k`.                     |                |                       |    |                                                   |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``SeekLe``  | Same as ``Seek``, but moving the cursor to the entry with the largest key less than or equal to :math:`k`          |                |                       |    |                                                   |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``IdxGt``   | A cursor :math:`c`                                                                                                 | A jump address | A register :math:`r`. |    | Cursor :math:`c` points to an index entry         |
|             |                                                                                                                    | :math:`j`      | The register must     |    | containing a :math:`(IdxKey,PKey)` pair.          |
|             |                                                                                                                    |                | contain a key         |    | If :math:`IdxKey` is greater than :math:`k`,      |
|             |                                                                                                                    |                | :math:`k`             |    | jump to :math:`j`. Otherwise, do nothing.         |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``IdxGe``   | Same as ``IdxGt``, but testing for :math:`IdxKey` being greater than or equal to :math:`k`.                        |                |                       |    |                                                   |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``IdxLt``   | Same as ``IdxGt``, but testing for :math:`IdxKey` being less than :math:`k`.                                       |                |                       |    |                                                   |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+
| ``IdxLe``   | Same as ``IdxGt``, but testing for :math:`IdxKey` being less than or equal to :math:`k`.                           |                |                       |    |                                                   |
+-------------+--------------------------------------------------------------------------------------------------------------------+----------------+-----------------------+----+---------------------------------------------------+

 
Cursor Access Instructions
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. cssclass:: table-bordered

+-------------+--------------------+-----------------------+-----------------------+----+--------------------------------------------------+
| Instruction | P1                 | P2                    | P3                    | P4 | Description                                      |
+=============+====================+=======================+=======================+====+==================================================+
| ``Column``  | A cursor :math:`c` | A column number       | A register :math:`r`. |    | Store in register :math:`r` the value in the     |
|             |                    | :math:`n`             |                       |    | :math:`n`-th column of the entry pointed at by   |
|             |                    |                       |                       |    | cursor :math:`c`. Columns are numbered from 0.   |
+-------------+--------------------+-----------------------+-----------------------+----+--------------------------------------------------+
| ``Key``     | A cursor :math:`c` | A register :math:`r`. |                       |    | Store in register :math:`r` the value of the     |
|             |                    |                       |                       |    | key of the entry pointed at by cursor :math:`c`. |
+-------------+--------------------+-----------------------+-----------------------+----+--------------------------------------------------+
| ``IdxPKey`` | A cursor :math:`c` | A register :math:`r`. |                       |    | Cursor :math:`c` points to an index entry        |
|             |                    |                       |                       |    | containing a :math:`(IdxKey,PKey)` pair. Store   |
|             |                    |                       |                       |    | :math:`PKey` in :math:`r`.                       |
+-------------+--------------------+-----------------------+-----------------------+----+--------------------------------------------------+





Database Record Instructions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. cssclass:: table-bordered

+----------------+----------------------+----------------------+-------------+----+------------------------------------------------+
| Instruction    | P1                   | P2                   | P3          | P4 | Description                                    |
+================+======================+======================+=============+====+================================================+
| ``MakeRecord`` | A register           | An integer :math:`n` | A register  |    | Create a database record using the values from |
|                | :math:`r_1`          |                      | :math:`r_2` |    | registers :math:`r_1` through :math:`r_1+n-1`, |
|                |                      |                      |             |    | and store the record in :math:`r_2`.           |
+----------------+----------------------+----------------------+-------------+----+------------------------------------------------+
| ``ResultRow``  | A register :math:`r` | An integer :math:`n` |             |    | This instructions indicates that a result row  |
|                |                      |                      |             |    | has been produced and pauses execution for the |
|                |                      |                      |             |    | database machine user to fetch the result row. |
|                |                      |                      |             |    | The result row is formed by the values stored  |
|                |                      |                      |             |    | in registers :math:`r` through :math:`r+n-1`.  |
+----------------+----------------------+----------------------+-------------+----+------------------------------------------------+



Insertion Instructions
~~~~~~~~~~~~~~~~~~~~~~

.. cssclass:: table-bordered

+---------------+--------------------+--------------------+-------------------+----+------------------------------------------------+
| Instruction   | P1                 | P2                 | P3                | P4 | Description                                    |
+===============+====================+====================+===================+====+================================================+
| ``Insert``    | A cursor :math:`c` | A register         | A register        |    | Inserts an entry, with key :math:`k` and value |
|               |                    | :math:`r_1`.       | :math:`r_2`.      |    | :math:`v`, in the B-Tree pointed at by cursor  |
|               |                    | The register must  | The register must |    | :math:`c`.                                     |
|               |                    | contain a database | contain a key     |    |                                                |
|               |                    | record :math:`v`   | :math:`k`         |    |                                                |
+---------------+--------------------+--------------------+-------------------+----+------------------------------------------------+
| ``IdxInsert`` | A cursor :math:`c` | A register         | A register        |    | Add a new :math:`(IdxKey,PKey)` entry in the   |
|               |                    | :math:`r_1`.       | :math:`r_2`.      |    | index B-Tree pointed at by cursor :math:`c`.   |
|               |                    | The register must  | The register must |    |                                                |
|               |                    | contain a key      | contain a key     |    |                                                |
|               |                    | :math:`IdxKey`     | :math:`PKey`      |    |                                                |
+---------------+--------------------+--------------------+-------------------+----+------------------------------------------------+


B-Tree Creation Instructions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. cssclass:: table-bordered

+-----------------+--------------------------------------------------------+----+----+----+----------------------------------------------+
| Instruction     | P1                                                     | P2 | P3 | P4 | Description                                  |
+=================+========================================================+====+====+====+==============================================+
| ``CreateTable`` | A register :math:`r`                                   |    |    |    | Create a new table B-Tree and store its root |
|                 |                                                        |    |    |    | page in :math:`r`.                           |
+-----------------+--------------------------------------------------------+----+----+----+----------------------------------------------+
| ``CreateIndex`` | Same as ``CreateTable``, but creating an index B-Tree. |    |    |    |                                              |
+-----------------+--------------------------------------------------------+----+----+----+----------------------------------------------+



