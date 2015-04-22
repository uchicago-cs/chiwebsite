=====
chidb
=====

chidb is a didactic relational database management system (RDBMS) designed for teaching how a RDBMS is built internally, from the data organization in files all the way up to the SQL parser and query optimizer. The design of chidb is based on `SQLite <https://sqlite.org/>`_, with several simplifying assumptions that make it possible to develop a complete chidb implementation over the course of a quarter or semester. One of the key similarities is that chidb uses a single file to store all its information (database metadata, tables, and indexes). In fact, the chidb file format is a subset of SQLite, meaning that well-formed chidb files will also be well-formed SQLite files (the opposite, though, is not necessarily true).

.. toctree::
   :maxdepth: 2

   intro.rst
   fileformat.rst
   architecture.rst
   installing.rst
   assignment_btree.rst
   assignment_dbm.rst
   testing.rst
   shell.rst
   
   
