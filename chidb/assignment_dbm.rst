.. _chidb-assignment-dbm:

Assignment II: Database Machine
===============================

In this second assignment, you will build upon the first assignment and implement
the chidb :ref:`Database Machine <chidb-dbm>` (DBM). You are provided with 
scaffolding code that will allow you to focus just on implementing the
individual instructions of the DBM.

This assignment is divided into the following parts:

#. Implement the Register Manipulation Instructions
#. Implement the Control Flow Instructions
#. Implement Cursors and Cursor Instructions for Table B-Trees
#. SELECT queries
#. INSERT statements
#. CREATE TABLE statements
#. Index operations

It is actually possible to implement each instruction by itself, but certain
DBM programs require that certain instructions are implemented first. The above
order will allow you to first test your code with simple DBM programs, and slowly
build up to running DBM programs equivalent to SQL queries. 

Before you start working on this assignment, make sure to read the
:ref:`Database Machine <chidb-dbm>` section of the :ref:`chidb-architecture`.


DBM code
--------

The implementation of the DBM is spread out across several files:

* ``dbm.[ch]``: Provides functions to create, modify, and run DBMs.
* ``dbm-types.h``: Header file that defines a number of types used to implement
  the DBM, including registers, instructions, etc.
* ``dbm-ops.c``: Provides the implementation of each individual instruction. 
  Most of your work will take place in this file.
* ``dbm-cursor.[ch]``: Mostly empty files where database cursors must be implemented.
  Part of your work will take place in these files.
  
Note that there is also a ``dbm-file.[ch]`` module which you can safely ignore. It is used
to read in text versions of DBM programs and, although it is used extensively in the tests,
understanding how these files are read is not essential to implementing the DBM.  
  
The DBM source code includes abundant documentation as code comments. We encourage you
to read through these files to understand the basics of how the DBM works. In particular,
you should make sure to read and understand the following:

* The ``struct chidb_stmt`` type. This is the struct that represents a single DBM program.
  Notice how a single DBM program has its own registers and cursors; unlike the type of
  programs you are accustomed to, the DBM programs don't share registers and other resources.
  Each program is, in essence, a self-contained machine.
  
  The reason why this type is called ``stmt`` (short for "statement") is because a SQL *statement*
  is compiled into a DBM. In this assignment, you don't have to worry about generating
  DBM code from SQL statements; we provide many DBM programs that you can use to test your
  implementation.
* The ``chidb_dbm_register_t`` and ``chidb_dbm_op_t`` types, representing DBM registers and operations
  respectively.
* The ``chidb_stmt_exec()`` function. This is the function that *runs* a DBM program. It calls
  ``chidb_dbm_op_handle()`` in ``dbm-ops.c`` which, in turn, uses a dispatch table to invoke
  the instruction that is being pointed by the *program counter*.

File ``dbm-ops.c`` contains one function for each of the DBM operations (these are the functions that
are called via a dispatch table). All of them have the same function signature. For example, this is
the function that implements the ``Integer`` operation::

   int chidb_dbm_op_Integer (chidb_stmt *stmt, chidb_dbm_op_t *op)
   {
       /* Your code goes here */
   
       return CHIDB_OK;
   }
   
The function has two parameters: ``stmt``, a pointer to the DBM this instruction is being run on, and
``op``, the specific instruction in the program that is being run. For example, suppose the program contained
this instruction::

   Integer 10 5 _ _
   
Then, when the program counter is pointing to that instruction, ``chidb_dbm_op_Integer`` would be called with
a ``chidb_dbm_op_t`` parameter where the ``opcode`` field is set to ``Op_Integer``, the ``p1`` field is set 
to ``10``, and the ``p2`` field is set to ``5``. ``p3`` and ``p4`` would contain undefined values, since their
values are not defined for the ``Integer`` operation.

Your implementation of ``chidb_dbm_op_Integer`` would simply have to take the value of ``op->p1`` and store it
in register ``op->p2`` (i.e., ``stmt->reg[op->p2]``). Note that you may have to allocate more registers
with ``realloc_reg()``, and that you can't just do an assignment like ``stmt->reg[op->p2] = op->p1`` because
registers are of type ``chidb_dbm_register_t`` (you must set the type of the register appropriately, and
set the correct field of the ``chidb_dbm_register_t`` struct). 

Testing your DBM
----------------

Most of your testing will involve running DBM programs written in the :ref:`DBM File Format <chidb-dbmf>`.
All these programs are stored in ``tests/files/dbm-programs``, and are run automatically by ``make check``.
The steps below also specify the location of the test programs that correspond to each step, as well
as how to run the tests only on those files.

When testing your implementation, you may also want to use the ``.dbmrun`` command in the
:ref:`chidb shell <chidb-shell>`


Step 1: Implement the Register Manipulation Instructions
--------------------------------------------------------

Implement the following instructions:

* ``Integer``
* ``String``
* ``Null``

The DBM programs to test these instructions are located in ``tests/files/dbm-programs/register/``.

You can run just those DBM programs by running the following::

   make tests/check_dbm && CK_RUN_SUITE="dbm-register" tests/check_dbm


Step 2: Implement the Control Flow Instructions
-----------------------------------------------

Implement the following instructions:

* ``Eq``
* ``Ne``
* ``Lt``
* ``Le``
* ``Gt``
* ``Ge``
* ``Halt``

Note: You are not required to support error codes or messages in ``Halt``. You can
assume the ``Halt`` instruction is always called with a value in P1, but the behaviour
of the instruction is the same regardless of the value of P1: it must halt the execution
of the DBM.


The DBM programs to test these instructions are located in ``tests/files/dbm-programs/flow/``.

You can run just those DBM programs by running the following::

   make tests/check_dbm && CK_RUN_SUITE="dbm-flow" tests/check_dbm
   
Step 3: Implement Cursors and Cursor Instructions for Table B-Trees
-------------------------------------------------------------------

Implement the following instructions:

* ``OpenRead``
* ``OpenWrite``
* ``Close``
* ``Rewind``
* ``Next``
* ``Prev``
* ``Seek``
* ``SeekGt``
* ``SeekGe``
* ``SeekLt``
* ``SeekLe``

To implement these instructions, you will have to implement a cursor type in ``dbm-cursor.[ch]``.
Do not underestimate the effort required to implement cursors: they can be a tricky
data structure to get right. We strongly encourage you to think through how the data structure
itself will be implemented, and what functions you will implement around that data structure.

For full credit, cursors must be able to move to the next or previous 
entry in a B-Tree in *amortized* :math:`O(1)` time (or, very informally: *most*, but not all,
of the times you move to the next or previous entry, the operation must happen in :math:`O(1)` time)
*and* use no more than :math:`O(\log(n))` space. As a first approximation to your cursor implementation,
we suggest you ignore the :math:`O(\log(n))` space restriction (which allows for trivial solutions
like simply loading an entire table into an array, and using that as your cursor). 
 
The DBM programs to test these instructions are located in ``tests/files/dbm-programs/cursor/``.

You can run just those DBM programs by running the following::

   make tests/check_dbm && CK_RUN_SUITE="dbm-cursor" tests/check_dbm
   
Take into account that these programs only perform some rudimentary tests on cursors, and they may
pass even with incomplete implementations of cursors. The reason for this is that, at this point,
you haven't implemented the column access functions, so it is not possible to check whether a cursor
is actually in the correct position. However, the programs do test most basic operations on cursors so,
if you pass all these tests, it's probably safe to move on to the next steps of the assignment.

Step 4: SELECT queries
----------------------

Implement the following instructions:

* ``ResultRow``
* ``Column``
* ``Key``

Once you have implemented these instructions, along with cursors, your DBM will be complete enough
to run DBM programs equivalent to SELECT queries. 

Some basic DBM programs to test ``ResultRow`` are located in ``tests/files/dbm-programs/record/``.

You can run just those DBM programs by running the following::

   make tests/check_dbm && CK_RUN_SUITE="dbm-record" tests/check_dbm
   
Several DBM programs equivalent to SELECT queries are located in ``tests/files/dbm-programs/sql-select/``.
The files themselves contain comments specifying what SQL query the program corresponds to.

You can run just those DBM programs by running the following::

   make tests/check_dbm && CK_RUN_SUITE="dbm-sql-select" tests/check_dbm

Step 5: INSERT statements
-------------------------

Implement the following instructions:

* ``MakeRecord``
* ``Insert``

Once you have implemented these instructions, along with cursors, your DBM will be complete enough
to run DBM programs equivalent to INSERT statements. 
   
Several DBM programs equivalent to INSERT queries are located in ``tests/files/dbm-programs/sql-insert/``.
The files themselves contain comments specifying what SQL query the program corresponds to.

You can run just those DBM programs by running the following::

   make tests/check_dbm && CK_RUN_SUITE="dbm-sql-insert" tests/check_dbm
   
   
Step 6: CREATE TABLE statements
-------------------------------

Implement the following instruction:

* ``CreateTable``

Once you have implemented these instructions, along with INSERT statements and cursors, your DBM will be complete enough
to run DBM programs equivalent to CREATE TABLE statements. 
   
Several DBM programs equivalent to CREATE TABLE queries are located in ``tests/files/dbm-programs/sql-create/``.
The files themselves contain comments specifying what SQL query the program corresponds to.

You can run just those DBM programs by running the following::

   make tests/check_dbm && CK_RUN_SUITE="dbm-sql-create" tests/check_dbm
   
   
Step 7: Index operations
------------------------

Implement the following instructions:

* ``IdxGt``
* ``IdxGe``
* ``IdxLt``
* ``IdxLe``
* ``IdxPKey``
* ``IdxInsert``
* ``CreateIndex``

Once you have implemented these instructions, along with cursors, your DBM will be complete enough
to run programs that create, manipulate, and query Index B-Trees.

**NOTE**: The index tests are not yet available, but will be added soon.

..
   Several DBM programs to test the index instructions are located in ``tests/files/dbm-programs/index/``.
   The files themselves contain comments specifying what SQL query the program corresponds to.
   
   You can run just those DBM programs by running the following::
   
      make tests/check_dbm && CK_RUN_SUITE="dbm-index" tests/check_dbm
   
      