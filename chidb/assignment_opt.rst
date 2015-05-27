.. _chidb-assignment-opt:

Assignment IV: Query Optimization
=================================

Pushing Sigmas
--------------

This part of project 4 does not entail code generation, only manipulation
of internal code representation during the optimization phase. Until this
point, the optimizer (see ``optimizer.c`` and ``api.c``) performed a "null
optimization" on all SQL queries compiled at the shell.

For project 4, the shell will have been augmented with a ``.opt`` command that
is reminiscent of the ``.parse`` command. To use ``.opt``, type a SQL statement in
quotes, the shell will respond by printing the parsed statement both before
and after optimization. It will not proceed to the code generation phase.

When ``.opt`` is applied to a statement that is not subject to optimization, the 
same parse tree will appear twice, like so::

   chidb> .opt "SELECT * FROM t;"
   Project([*],
           Table(t)
   )
   
   Project([*],
           Table(t)
   )
   chidb>

However, given a statement the can be optimized, the results will show a change, like so::

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

where cmp is of the form [val-or-col] oper [val-or-col].

Please note that

::

   SELECT *
   FROM  t1 NATURAL JOIN t2
   WHERE t1.a < t2.b;</pre>

is of this form, but contains no sigmas that can be pushed.