About
=====

This repository contains the SQLite amalgamation and the
corresponding Makefiles to build the shell/library. This
code is public domain. For more information see the
https://www.sqlite.org/ website.

SQL Quick Reference Guide
=========================

Basic Syntax
------------

Comments include (--) for single line and (/* */) for
multi-line.

Strings are enclosed in single quotes (' ') and
concatenation is performed with the (||) operator. C-style
backslash escapes are not supported.

Blobs are represented by a string of hexadecimal
characters (x'A554E59C').

Bitwise operators include ~, |, &, <<, >>, AND, OR.

Logic values in SQL use Three-Valued Logic (3VL) which
include TRUE, FALSE or NULL. Boolean operators include NOT,
<, <=, >=, >, =, ==, !=, <>. Additional logic operators
include IN, LIKE, GLOB, MATCH and REGEXP.

Columns may include fully qualified column names such as
([[database\_name.]table\_name.]column\_name).

Note that some operators listed are supported by SQLite but
are not part of the SQL standard.

CREATE/DROP TABLE
-----------------

Tables are the only data structure supported by SQL which
have columns that represent a unique type and rows which
represent data elements.

To create/drop a table.

	CREATE TABLE table_name
	(
	    column_name column_type column_constraints [, ...]
	);

	column_type:
		INTEGER: A signed integer number from 1-8 bytes
		FLOAT: An 8-byte floating point number
		TEXT: A variable length string
		BLOB: A Binary Length Object
		NULL: A NULL type does not hold a value

	column_constraints:
	    constraint [...]

	constraint:
		PRIMARY KEY: Columns used to index the table
		REFERENCES table[.column]: A foreign key reference
		UNIQUE: Require each row to be unique
		NOT NULL: Each row must be unique

	CREATE [TEMP] TABLE table_name AS SELECT query_statement;

	DROP TABLE table_name;

Note that internally SQLite treats the column_type as an
affinity which it uses to perform type conversions as
needed.

Note that if an INTEGER PRIMARY key is not defined then
SQLite will create a hidden ROWID column for this purpose.

Note that a PRIMARY KEY implies UNIQUE but may still be
NULL.

Note that TEMP tables are dropped when the database
connection is closed. The TEMP flag is optional but is
recommended when creating tables from queries since there
is no way to define the column constraints. See the INSERT
command for more details.

Note that there are additional column constraints that are
not listed above which may not work well when combined
with the C API.

ALTER TABLE
-----------

Altering tables is primarily useful when significant
changes are required to a table. The procedure involves
renaming an existing table, creating a new table under the
original name, copying data from the old table and then
dropping the old table. New columns may also be added to
the table.

CREATE/DROP VIEW
----------------

A view is essentially a query packaged into a read-only
table that is updated dynamically every time the view is
referenced.

To create/drop a view.

	CREATE [TEMP] VIEW view_name AS SELECT query_statement;

	DROP VIEW view_name;

CREATE/DROP INDEX
-----------------

Indexes are used by SQLite to optimize database performance
by indexing one or more columns of a table. Some indexes
are created automatically by SQLite for PRIMARY KEY and
UNIQUE columns. The user may also optionally define indexes
for commands that it expects to issue. The following factors
should be considered before creating multicolumn indexes.
The column order is very important because the data is
sorted by column in the order specified by the index. In
order to utilize a multicolumn index, a query must contain
conditions that are able to utilize the sort keys in the
same order defined by the index. A query may use a subset of
the available index columns. A single multicolumn index is
different than multiple single-column indexes. A query
optimizer may only utilize a single index to compute the
result (with the exception of a series of OR conditions).
The query optimizer automatically chooses which indexes it
will use but these choices are opaque to the user and may
not be what was expected. The ANALYZE command can be used to
provide statistical imformation on the query optimizer.

To create/drop an index.

	CREATE [UNIQUE] INDEX index_name ON table_name (column_name [, ...] );

	DROP INDEX index_name;

The UNIQUE flag indicates that the index will prevent
duplicate values from being inserted into the table. The
UNIQUE flag on the index differs from the UNIQUE flag on
the table column in two ways. It allows the UNIQUE
constraint to be applied across multiple columns and the
UNIQUE constraint may be removed by dropping the index.

INSERT/REPLACE
--------------

To insert rows into a table or ignore/replace the insert if
a duplicate row exists when the UNIQUE constraint is
defined.

	INSERT [OR IGNORE] INTO table_name (column_name [, ...]) VALUES (new_value [, ...]);

	INSERT [OR IGNORE] INTO table_name (column_name [, ...]) SELECT query_statement;

	REPLACE INTO table_name (column_name [, ...]) VALUES (new_value [, ...]);

	REPLACE INTO table_name (column_name [, ...]) SELECT query_statement;

Note that bulk inserts can be sped up by wrapping INSERT
commands inside a transaction or using the shell .import
command.

UPDATE
------

To update row(s) in a table for one or more columns.

	UPDATE table_name SET column_name=new_value [, ...] WHERE expression;

DELETE
------

To delete rows from a table.

	DELETE FROM table_name WHERE expression;

SELECT
------

To select data from the database.

	SELECT [DISTINCT] select_heading
	    [FROM source_tables]
	    [WHERE filter_expression]
	    [GROUP BY grouping_expressions
	        [HAVING filter_expressions]]
	    [ORDER BY ordering_expressions]
	    [LIMIT count
	        [OFFSET count]];

	select_heading (expression may include ROWID or *):
	    expression [AS column_alias] [, ...]

	source_tables:
	    t1 [ AS x ] CROSS JOIN t2 [ AS y ] [...]
	    t1 [ AS x ] JOIN t2 [ AS y ] ON conditional_expression [...]
	    t1 [ AS x ] JOIN t2 [ AS y ] USING ( col1 [, ...] ) [...]
	    t1 [ AS x ] NATURAL JOIN t2 [...]
	    t1 [ AS x ] LEFT OUTER JOIN t2 [ AS y ] ON conditional_expression [...]

	grouping_expressions:
	    grouping_expression [COLLATE collation_name] [, ...]

	ordering_expressions:
	    expression [COLLATE collation_name] [ASC|DESC] [, ...]

	collation_name:
	    BINARY | NOCASE | RTRIM

A subquery allows nesting of SELECT statements as follows.

	SELECT ... FROM ( SELECT ... ) AS z ...;

To summarize the clauses.

* FROM: Combines the source_tables into the working table
* WHERE: Filter specific rows out of the working table
* GROUP BY: Groups sets of rows in the working table
* HAVING: Filters specific rows out of the grouped table
* ORDER BY: Sorts rows of the result set (expensive)
* LIMIT: Limits the result set to a specific number of rows
* OFFSET: Skips over rows at the beginning of the result set

The DISTINCT flag eliminate duplicate rows from the result
table. This is an expensive operation and typically
unneeded because the output columns typically include a
unique PRIMARY KEY column.

The select\_heading determines how groups are flattened into
a single row using aggregate functions (e.g. count(),
min(), max()). Note that when using aggregate functions,
any columns which were not aggregated will contain a value
from a random row of the group. To avoid this, when using a
GROUP BY clause, the select\_heading should only use column
references for grouping\_expressions or aggregate function
outputs.

The AS statement in the select\_heading assigns a
column\_alias to one of the output columns. It is
recommended to provide column aliases.

Joins define how pairs of tables are combined where rows of
x are paired with rows of y. The CROSS JOIN creates a new
table where each row in x is combined with each row of y
resulting in n*m rows. The INNER JOIN (JOIN) creates a new
table where the rows in x are combined with each row of y
where the condition holds true. The JOIN USING syntax is a
shortcut for JOIN ON where the conditional expression
would be x.col1 = y.col1. The NATURAL JOIN is a shortcut
for JOIN USING where all column names which match between
t1 and t2 are included in the column list. The LEFT OUTER
JOIN is identical to the INNER JOIN except that it replaces
unmatched rows with NULLs.

The AS statement in the source\_tables creates a table
alias to avoid ambiguity when working with self joins or
subqueries. You must use the alias once it has been
assigned. It is recommended to use table aliases.

Typically a grouping\_expression will reference a
select\_heading column\_alias. If the grouping\_expression
involves a text value then the collation can be given to
determine which values are equivalent. A
grouping\_expression may also reference a column\_alias from
the result table.

The WHERE and HAVING clauses are functionally identical
except that they are evaluated at different stages of the
SELECT pipeline. The WHERE clause is evaluated when
producing the inital working table and the HAVING clause is
evaluated on the GROUP BY output table. The WHERE clause
cannot reference aggregate function columns while the
HAVING clause may reference any result column.

References
----------

Using SQLite by Jay A. Kreibich (O'Reilly)
