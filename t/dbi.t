#!/usr/bin/perl -w

use strict;
use Test::More;
use utf8;
use URI;

for my $spec (
    {
        uri => 'db:',
        dsn => '',
        dbi => [ [host => undef], ['port' => undef], [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:pg:',
        dsn => 'dbi:Pg:',
        dbi => [ [host => undef], [port => undef], [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:pg://localhost',
        dsn => 'dbi:Pg:host=localhost',
        dbi => [ [host => 'localhost'], [port => undef], [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:pg://localhost',
        dsn => 'dbi:Pg:host=localhost',
        dbi => [ [host => 'localhost'], [port => undef], [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:pg://me:secret@example.com/foodb',
        dsn => 'dbi:Pg:host=example.com;dbname=foodb',
        dbi => [ [host => 'example.com'], [port => undef], [dbname => 'foodb'] ],
        qry => [],
    },
    {
        uri => 'db:pg://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:postgresql://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:postgres://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:postgresxc://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:pgsql://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:pgxc://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:redshift://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:sqlite:',
        dsn => 'dbi:SQLite:',
        dbi => [ [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:sqlite:foo.db',
        dsn => 'dbi:SQLite:dbname=foo.db',
        dbi => [ [dbname => 'foo.db'] ],
        qry => [],
    },
    {
        uri => 'db:sqlite:/path/foo.db',
        dsn => 'dbi:SQLite:dbname=/path/foo.db',
        dbi => [ [dbname => '/path/foo.db'] ],
        qry => [],
    },
    {
        uri => 'db:sqlite:///path/foo.db',
        dsn => 'dbi:SQLite:dbname=path/foo.db',
        dbi => [ [dbname => 'path/foo.db'] ],
        qry => [],
    },
    {
        uri => 'db:cubrid://localhost:33/foo',
        dsn => 'dbi:cubrid:host=localhost;port=33;database=foo',
        dbi => [ [host => 'localhost'], [port => 33], [database => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:db2://localhost:33/foo',
        dsn => 'dbi:DB2:HOSTNAME=localhost;PORT=33;DATABASE=foo',
        dbi => [ [HOSTNAME => 'localhost'], [PORT => 33], [DATABASE => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:firebird://localhost:33/foo',
        dsn => 'dbi:Firebird:host=localhost;port=33;dbname=foo',
        dbi => [ [host => 'localhost'], [port => 33], [dbname => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:informix:foo.db',
        dsn => 'dbi:Informix:foo.db',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:informix:foo.db?foo=1',
        dsn => 'dbi:Informix:foo.db;foo=1',
        dbi => [],
        qry => [foo => 1],
    },
    {
        uri => 'db:ingres:foo.db',
        dsn => 'dbi:Ingres:foo.db',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:ingres:foo.db?foo=1',
        dsn => 'dbi:Ingres:foo.db;foo=1',
        dbi => [],
        qry => [foo => 1],
    },
    {
        uri => 'db:interbase://localhost:33/foo',
        dsn => 'dbi:InterBase:host=localhost;port=33;dbname=foo',
        dbi => [ [host => 'localhost'], [port => 33], [dbname => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:ldapdb://localhost:33/foo',
        dsn => 'dbi:LDAP:foo',
        dbi => [ [ dbname => 'foo' ] ],
        qry => [],
    },
    {
        uri => 'db:ldapdb://localhost/foo',
        dsn => 'dbi:LDAP:foo',
        dbi => [ [ dbname => 'foo' ] ],
        qry => [],
    },
    {
        uri => 'db:ldapdb://./foo',
        dsn => 'dbi:LDAP:foo',
        dbi => [ [ dbname => 'foo' ] ],
        qry => [],
    },
    {
        uri => 'db:maxdb://localhost:33/foo',
        dsn => 'dbi:MaxDB:localhost:33/foo',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:maxdb://localhost/foo',
        dsn => 'dbi:MaxDB:localhost/foo',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:monetdb://localhost:1222?foo=1',
        dsn => 'dbi:monetdb:host=localhost;port=1222;foo=1',
        dbi => [ [host => 'localhost'], [port => 1222] ],
        qry => [foo => 1],
    },
    {
        uri => 'db:monetdb://localhost/lolz',
        dsn => 'dbi:monetdb:host=localhost',
        dbi => [ [host => 'localhost'], [port => undef] ],
        qry => [],
    },
    {
        uri => 'db:mysql://localhost:33/foo',
        dsn => 'dbi:mysql:host=localhost;port=33;database=foo',
        dbi => [ [host => 'localhost'], [port => 33], [database => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:mariadb://localhost:33/foo',
        dsn => 'dbi:mysql:host=localhost;port=33;database=foo',
        dbi => [ [host => 'localhost'], [port => 33], [database => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:oracle://localhost:33/foo',
        dsn => 'dbi:Oracle:host=localhost;port=33;sid=foo',
        dbi => [ [host => 'localhost'], [port => 33], [sid => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:oracle:foo',
        dsn => 'dbi:Oracle:foo',
        dbi => [ [host => undef], [port => undef], [sid => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:mssql:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
        alt => { odbc => 'dbi:ODBC:', sybase => 'dbi:Sybase:' },
    },
    {
        uri => 'db:mssql:dbadmin',
        dsn => 'dbi:ODBC:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
        alt => {
            ado    => 'dbi:ADO:DSN=dbadmin',
            sybase => 'dbi:Sybase:dbname=dbadmin',
        },
    },
    {
        uri => 'db:mssql://localhost',
        dsn => 'dbi:ODBC:Server=localhost;Port=1433',
        dbi => [ [Server => 'localhost'], [Port => 1433], [Database => undef] ],
        qry => [],
        alt => {
            ADO    => 'dbi:ADO:Server=localhost',
            ODBC   => 'dbi:ODBC:Server=localhost;Port=1433',
            SYBASE => 'dbi:Sybase:host=localhost',
        },
    },
    {
        uri => 'db:mssql://localhost:33',
        dsn => 'dbi:ODBC:Server=localhost;Port=33',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => undef] ],
        qry => [],
        alt => {
            ado    => 'dbi:ADO:Server=localhost;Port=33',
            sybase => 'dbi:Sybase:host=localhost;port=33',
        },
    },
    {
        uri => 'db:mssql://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPMssql',
        dsn => 'dbi:ODBC:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=HPMssql',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPMssql' ],
        alt => {
            ado    => 'dbi:ADO:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=HPMssql',
            sybase => 'dbi:Sybase:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes;Driver=HPMssql',
        },
    },
    {
        uri => 'db:mssql://localhost:33/foo',
        dsn => 'dbi:ODBC:Server=localhost;Port=33;Database=foo',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => 'foo'] ],
        qry => [],
        alt => {
            ado    => 'dbi:ADO:Server=localhost;Port=33;Database=foo',
            sybase => 'dbi:Sybase:host=localhost;port=33;dbname=foo',
        },
    },
    {
        uri => 'db:sqlserver://localhost:33/foo',
        dsn => 'dbi:ODBC:Server=localhost;Port=33;Database=foo',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => 'foo'] ],
        qry => [],
        alt => {
            Ado    => 'dbi:ADO:Server=localhost;Port=33;Database=foo',
            Odbc   => 'dbi:ODBC:Server=localhost;Port=33;Database=foo',
            Sybase => 'dbi:Sybase:host=localhost;port=33;dbname=foo',
        },
    },
    {
        uri => 'db:sybase://localhost:33/foo',
        dsn => 'dbi:Sybase:host=localhost;port=33;dbname=foo',
        dbi => [ [host => 'localhost'], [port => 33], [dbname => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:teradata://localhost',
        dsn => 'dbi:Teradata:localhost',
        dbi => [ [DATABASE => undef] ],
        qry => [],
    },
    {
        uri => 'db:teradata://localhost:33/foo?hi=1',
        dsn => 'dbi:Teradata:localhost:33;DATABASE=foo;hi=1',
        dbi => [ [DATABASE => 'foo'] ],
        qry => [ hi => 1],
    },
    {
        uri => 'db:unify:foo.db',
        dsn => 'dbi:Unify:foo.db',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:unify:',
        dsn => 'dbi:Unify:',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:unify:?foo=1&bar=2',
        dsn => 'dbi:Unify:foo=1;bar=2',
        dbi => [],
        qry => [ foo => 1, bar => 2 ],
    },
    {
        uri => 'db:vertica:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
    },
    {
        uri => 'db:vertica:dbadmin',
        dsn => 'dbi:ODBC:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
    },
    {
        uri => 'db:vertica://localhost',
        dsn => 'dbi:ODBC:Server=localhost;Port=5433',
        dbi => [ [Server => 'localhost'], [Port => 5433], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:vertica://localhost:33',
        dsn => 'dbi:ODBC:Server=localhost;Port=33',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:vertica://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPVertica',
        dsn => 'dbi:ODBC:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=HPVertica',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPVertica' ],
    },
    {
        uri => 'db:exasol:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
        alt => { odbc => 'dbi:ODBC:', EXASOL => 'dbi:ODBC:' },
    },
    {
        uri => 'db:exasol:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
    },
    {
        uri => 'db:exasol:dbadmin',
        dsn => 'dbi:ODBC:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
    },
    {
        uri => 'db:exasol://localhost',
        dsn => 'dbi:ODBC:EXAHOST=localhost;EXAPORT=8563',
        dbi => [ [EXAHOST => 'localhost'], [EXAPORT => 8563] ],
        qry => [],
    },
    {
        uri => 'db:exasol://localhost:33',
        dsn => 'dbi:ODBC:EXAHOST=localhost;EXAPORT=33',
        dbi => [ [EXAHOST => 'localhost'], [EXAPORT => 33] ],
        qry => [],
    },
    {
        uri => 'db:exasol://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPExasol',
        dsn => 'dbi:ODBC:EXAHOST=foo;EXAPORT=123;foo=1;foo=2;lol=yes;Driver=HPExasol',
        dbi => [ [EXAHOST => 'foo'], [EXAPORT => 123] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPExasol' ],
    },
    {
        uri => 'db:snowflake:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
    },
    {
        uri => 'db:snowflake:dbadmin',
        dsn => 'dbi:ODBC:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
    },
    {
        uri => 'db:snowflake://yow',
        dsn => 'dbi:ODBC:Server=yow;Port=443',
        dbi => [ [Server => 'yow'], [Port => 443], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:snowflake://yow:33',
        dsn => 'dbi:ODBC:Server=yow;Port=33',
        dbi => [ [Server => 'yow'], [Port => 33], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:snowflake://foo:123/try?foo=1&foo=2&lol=yes&Driver=Snowflaker',
        dsn => 'dbi:ODBC:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=Snowflaker',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'Snowflaker' ],
    },
    {
        uri => 'db:clickhouse:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
    },
    {
        uri => 'db:clickhouse:dbadmin',
        dsn => 'dbi:ODBC:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
    },
    {
        uri => 'db:clickhouse://yow',
        dsn => 'dbi:ODBC:Server=yow;Port=8123',
        dbi => [ [Server => 'yow'], [Port => 8123], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:clickhouse://yow:33',
        dsn => 'dbi:ODBC:Server=yow;Port=33',
        dbi => [ [Server => 'yow'], [Port => 33], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:clickhouse://foo:123/try?foo=1&foo=2&lol=yes&Driver=ClickHouse',
        dsn => 'dbi:ODBC:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=ClickHouse',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'ClickHouse' ],
    },
) {
    my $uri = $spec->{uri};
    ok my $u = URI->new($uri), "URI $uri";
    is_deeply [ $u->query_params ], $spec->{qry}, "... $uri query params";
    is_deeply [ $u->_dbi_param_map ], $spec->{dbi}, "... $uri DBI param map";
    is_deeply [ $u->dbi_params ], [
        (
            map { @{ $_ } }
            grep { defined $_->[1] && length $_->[1] } @{ $spec->{dbi} }
        ),
        @{ $spec->{qry} },
    ], "... $uri DBI params";
    is $u->dbi_dsn, $spec->{dsn}, "... $uri DSN";
    if (my $alt = $spec->{alt}) {
        while (my ($driver, $dsn) = each %{ $alt }) {
            is $u->dbi_dsn($driver), $dsn, "$uri $driver DSN";
        }
    }
}

done_testing;
