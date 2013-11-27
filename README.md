Database URI
============

This project proposes a standard for database connection URIs and provides a
simple Perl implementation. This figure summarizes the definition syntax and
for database URIs (illustration adapted from
[RFC 3986](http://tools.ietf.org/html/rfc3986) --- STD 66, chapter 3):

      db:engine://username:password@example.com:8042/over/there/widget.db?type=animal&name=narwhal
      \/ \____/   \_______________/ \________/ \__/ \__________________/  \__/ \___/  \__/ \_____/
       |    |             |              |      |             |             |    |     |      |
       |    |         userinfo       hostname  port           |            key   |    key     |
       |    |      \________________________________/         |                  |            |
       |    |                      |                          |                value        value
       |  engine                   |                          |           \______________________/
    scheme  |                  authority          database name or path              |
     name   |      \____________________________________________________/          query
       |    |                           |
       |    |                   hierarchical part
       |    |
       |    |  database name or path     query
       |  __|_   ________|________    _____|____
      /\ /    \ /                 \  /          \
      db:engine:my_big_fat_database?subject=Topic

Notes on this syntax:

* The Database URI *scheme* is `db`. Consequently, database URIs always start
  with `db:`. This is the [URI scheme](http://en.wikipedia.org/wiki/URI_scheme)
  that defines a database URI.

* Next comes the database *engine*. This part is a string naming the type of
  database engine for the database. It must always be followed by a colon, `:`.
  There is no formal list of supported engines, though certain implementations
  may specify engine-specific semantics, such as a default port.

* The *authority* part is separated from the engine by a double slsah, `//`,
  and is terminated by the next slash. It consistes of an optional
  user-information part, terminated with `@` (e.g., `username:password@`); a
  required host address (e.g., domain name or IP address); and an optional
  port number, preceded by a colon, `:`.

* The *path* part specifies the database name or path. For URIs that contain
  an authority part, a path specifying a file name must be absolute. URIs
  without an authority may use absolute or relative paths.

* The optional *query* part, separated by a question mark, `?`, contains
  `key=value` pairs separated by a semicolon, `;`, or ampersand, `&`. These
  parameters may be used to configure a database connection.

Here are some database URIs without an authority part, which is typical for
non-server engines such as [SQLite](http://sqlite.org/), where the path part
is a relative or absolute file name:

* `db:sqlite:`
* `db:sqlite:foo.db`
* `db:sqlite:../foo.db`
* `db:sqlite:/var/db/foo.sqlite`

Other engines may not require a host name, either, but use a database name,
rather than a file name:

* `db:ingres:mydb`
* `db:pg:template1`

When a URI includes an authority part, it must be preceded by a double slash
and followed by a single slash:

* `db:pg://example.com/`
* `db:mysql://root@localhost/`
* `db:pg://postgres:secr3t@example.net`

To add the database name, separate it from the authority by a single slash:

* `db:postgresql://example.com/template1`
* `db:mongodb://localhost:27017/myDatabase`
* `db:oracle://scott:tiger@foo.com/scott`

Some databases, such as Firebird, take both a host name and a file path.
These paths must be absolute:

* `db:firebird://localhost/tmp/test.gdb`
* `db:firebird://localhost/C:/temp/test.gdb`

Any URI format may optinally have a query part conaining key/value pairs:

* `db:sqlite:foo.db?foreign_keys=ON;journal_mode=WAL`
* `db:pg://localhost:5433/postgres?client_encoding=utf8;connect_timeout=10`

### URI Compliance ###

Formally, a database URI as defined here is an opaque URI starting with `db:`
followed by an embedded server-style URI. For example, this database URI:

    db:pg://localhost/mydb

Is formally the URI `pg://localhost/mydb` embedded in an opaque `db:` URI. It
adheres to this formal definition because the scheme part of a URI is not
allowed to contain a sub-scheme (or subprotocol, in the
[JDBC parlance](http://docs.oracle.com/cd/B14117_01/java.101/b10979/urls.htm#BEIJFHHB)).
It is therefore a legal URI embedded in a second legal URI

Informally, it's simpler to think of a database URI as a single URI starting
with the combination of the scheme and the engine, e.g., `db:pg`.

### Inspiration ###

The format here is inspired by a lot of prior art.

* [JDBC URIs](http://docs.oracle.com/cd/B14117_01/java.101/b10979/urls.htm#BEIJFHHB)
  set the precedent for an opaque URI with a second, embedded URI, as
  [discussed here](https://groups.google.com/forum/#!topic/comp.lang.java.programmer/twkIYNaDS64).

* A number of database URI formats set the standard for `engine://authority/dbname`, including:
    * [PostgreSQL libpq URIs](http://www.postgresql.org/docs/9.3/static/libpq-connect.html#LIBPQ-CONNSTRING)
    * [SQLAlchemy URLs](http://docs.sqlalchemy.org/en/rel_0_9/core/engines.html#database-urls)
    * [Stackato database URLs](http://docs.stackato.com/3.0/user/services/data-services.html#database-url)
    * [Django database URLs](https://github.com/kennethreitz/dj-database-url)
    * [Rails database URLs](https://github.com/glenngillen/rails-database-url)

Author
------

[David E. Wheeler](http://theory.so/)
