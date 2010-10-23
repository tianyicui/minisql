MiniSQL
=======

This is my class project for Database Management Systems Design, fall 2010.

I will implement it in pure Ruby purely for fun, and maybe later translate some part (e.g. B+ tree) to C (but not necessarily by me).

Required features
-----------------

- Single-user DBMS (i.e. no transaction/concurrency involved).
- `CREATE TABLE`.
    * Three data types: `INT`, `CHAR(n)`, `FLOAT`. (1<=n<=255)
    * No more than 32 columns in a table, `UNIQUE` and `PRIMARY KEY` should be supported.
- `CREATE INDEX` using B+ tree.
- `SELECT * FROM table [WHERE conditions]`. In conditions, `=`, `<>`, `<`, `>`, `<=`, `>=`, `AND`, `OR` should be implemented.
- `INSERT INTO table VALUES ( value1, value2, ... )`.
- `DELETE FROM table [WHERE conditions]`.
- `EXECFILE filename`.
- `QUIT`.

Rough roadmap
-------------

1. Design the interface.
2. A mock implementation using SQLite.
3. Write a comprehensive test suite. The mock will make sure there are no bugs in test suite.
4. Make the pass radio grow! In this process, the SQLite library will be extensively used as much as possible. For example, after the SQL interpreter is written and SQL can be translated into intermediate data structure, a mock execution engine will be implemented using SQLite.
5. But this roadmap is not that solid, it's like this mainly because I'm interested in the topic of testing (or behavior-driving, spec-writing, whatever you call them today) in Ruby.

Additional features
-------------------

* I'd really like to show my teacher a sane transaction management implementation which can run queries concurrently and ensure atomicity.
* Maybe basic nested select and multi-table query support.
