.. _chidb-assignment-opt:

Assignment IV: Query Optimization
=================================

In this assignment, you will complete two tasks related to the optimization
of SQL queries: pushing sigmas and supporting indexes.

Pushing Sigmas
--------------

This part of project 4 does not entail code generation, only manipulation
of internal code representation during the optimization phase. Until this
point, the optimizer (see ``optimizer.c`` and ``api.c``) performed a null
optimization (i.e., did nothing) on all SQL queries compiled at the shell.

For project 4, the shell will have been augmented with a ``.opt`` command that
is reminiscent of the ``.parse`` command. To use ``.opt``, type a SQL statement in
quotes; the shell will respond by printing the parsed statement both before
and after optimization. It will not proceed from there to the code generation phase.

When .opt is applied to a statement that is not subject to optimization, the 
same parse tree will appear twice, like so::

    chidb> .opt "SELECT * FROM t;"
    Project([*],
            Table(t)
    )

    Project([*],
            Table(t)
    )
    chidb>

However, given a statement the can be optimized, the results will show the results of that optimization like so::

    chidb> .opt "SELECT * FROM t |><| u WHERE t.a>10;"
    Project([*],
            Select(t.a > int 10,
                    NaturalJoin(
                            Table(t),
                            Table(u)
                    )
            )
    )

    Project([*],
            NaturalJoin(
                    Select(t.a > int 10,
                            Table(t)
                    ),
                    Table(u)
            )
    )
    chidb>


Pushing sigmas means that sigmas are pushed as low in the table as possible, and specifically below natural joins.

You are responsible for pushing sigmas in queries where this form appears, either as all or part of the query::

    SELECT [fields]
    FROM   t1 NATURAL JOIN t2
    WHERE  [cmp] AND ... AND [cmp];

where cmp is of the form ``[val-or-col] [oper] [val-or-col]``, and ``oper`` is either >, <, <=, >=, or =. The "as all or part of the query" clause refers to the fact that this expression form might appear embedded in another form; for example, as part of a UNION, in which case you should still push its sigmas.

Please note that

::

    SELECT *
    FROM  t1 NATURAL JOIN t2
    WHERE t1.a < t2.b;

is of the pushing-sigmas form, but contains no sigmas that can be pushed.

Supporting Indexes
------------------

Modify your implementation so that it supports indexes in the following ways:

#. Support index creation through statements of the following form::

        chidb> CREATE INDEX i ON t(j);

   This statement should create a new index B-tree, insert the corresponding row into the schema table, and populate the index with entries relating to the current instance of the indexed table. For simplicity, you may assume that the indexed field, j, is a unique integer field, whether or not the values are actually unique in the table instance, and whether or not the column is qualified as a ``UNIQUE`` one. In other words, the index you build must be correct and complete when the values in the indexed field are pairwise distinct; otherwise the index-building behavior is undefined.

#. Update indexes whenever an indexed item is inserted by an ``INSERT INTO``.

#. Compile certain queries to make use of index searches where possible. These queries should be of the form

   ::

       SELECT [fields]
       FROM [table]
       WHERE [test-on-index];

   In these cases, ``[test-on-index]`` should be one of the following::

       [indexed-col] = [val]
       [val] = [indexed-col]

