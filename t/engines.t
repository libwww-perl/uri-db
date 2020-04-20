#!/usr/bin/perl -w

use strict;
use Test::More;
use utf8;
use URI;
use URI::QueryParam;

for my $spec (
    [ db         => undef,  undef       ],
    [ unknown    => undef,  undef       ],
    [ postgresql => 5432,  'pg'         ],
    [ postgres   => 5432,  'pg'         ],
    [ pgsql      => 5432,  'pg'         ],
    [ pg         => 5432,  'pg'         ],
    [ pgxc       => 5432,  'pg'         ],
    [ postgresxc => 5432,  'pg'         ],
    [ redshift   => 5432,  'pg'         ],
    [ mysql      => 3306,  'mysql'      ],
    [ mariadb    => 3306,  'mysql'      ],
    [ maria      => 3306,  'mysql'      ],
    [ sqlite     => undef, 'sqlite'     ],
    [ sqlite3    => undef, 'sqlite'     ],
    [ oracle     => 1521,  'oracle'     ],
    [ cubrid     => 33000, 'cubrid'     ], # ?
    [ firebird   => 3050,  'firebird'   ],
    [ mssql      => 1433,  'mssql'      ],
    [ sqlserver  => 1433,  'mssql'      ],
    [ db2        => 50000, 'db2'        ], # ?
    [ ingres     => 1524,  'ingres'     ],
    [ sybase     => 2638,  'sybase'     ],
    [ informix   => 1526,  'informix'   ], # ?
    [ teradata   => 1025,  'teradata'   ],
    [ interbase  => 3050,  'interbase'  ],
    [ unify      => 27117, 'unify'      ], # ?
    [ mongodb    => 27017, 'mongodb'    ],
    [ mongo      => 27017, 'mongodb'    ],
    [ monetdb    => 50000, 'monetdb'    ], # ?
    [ monet      => 50000, 'monetdb'    ], # ?
    [ maxdb      => 7673,  'maxdb'      ], # ?
    [ max        => 7673,  'maxdb'      ], # ?
    [ impala     => 21000, 'impala'     ],
    [ couchdb    => 5984,  'couchdb'    ],
    [ couch      => 5984,  'couchdb'    ],
    [ hive       => 10000, 'hive'       ],
    [ cassandra  => 9160,  'cassandra'  ],
    [ derby      => 1527,  'derby'      ],
    [ vertica    => 5433,  'vertica'    ],
    [ ldapdb     => undef, 'ldapdb'     ],
    [ exasol     => 8563,  'exasol'     ],
    [ snowflake  => 443,   'snowflake'  ],
    [ clickhouse => 8123,  'clickhouse' ],
) {
    my ($engine, $port, $canon) = @{ $spec };
    my $prefix = "db:$engine";
    my $class  = "URI::$engine";
    my $label  = $engine;
    my $clabel = $canon;
    if ($engine eq 'db' || $engine eq 'unknown') {
        $prefix = 'db';
        $class  = 'URI::_db';
        $engine = undef;
        $label  = '';
        $canon = undef;
        $clabel  = '';
    } else {
        # Should work well as a direct URI.
        my $string = "$engine://hi:there\@foo.com:1234/blah.db";
        isa_ok my $uri = URI->new($string), $class;
        isa_ok $uri, 'URI::_db';
        isa_ok $uri->uri, $class;
        is $uri->scheme, $engine, qq{Non-DB scheme should be "$engine"};
        is $uri->engine, $engine, qq{Non-DB URI engine should be "$label"};
        is $uri->dbname, 'blah.db', 'Simple URI db name should be "blah.db"';
        is $uri->host, 'foo.com', 'Non-DB URI host should be "foo.com"';
        is $uri->port, 1234, 'Non-DB URI port should be 1234';
        is $uri->user, 'hi', 'Non-DB URI user should be "hi"';
        is $uri->password, 'there', 'Non-DB URI password should be "there"';
        is_deeply $uri->query_form_hash, {},
            'Non-DB URI query params should be empty by default';
        is_deeply [ $uri->query_params ], [], 'Non-DB URI query params should be empty';
        is $uri->as_string, $string, 'Non-DB URI string should be correct';
        is "$uri", $string, 'Non-DB URI should correctly strigify';
        ok $uri->has_recognized_engine, "$engine should be recognized engine";
        is $uri->canonical_engine, $canon, qq{Non-DB URI canonical engine should be "$clabel"};
        $uri->port(undef) if $clabel eq 'sqlite' || $clabel eq 'ldapdb';
        is $uri->canonical->engine, $canon, qq{Non-DB URI canonical URI engine should be "$clabel"};
    }

    isa_ok my $uri = URI->new("$prefix:"), 'URI::db', "DB URI with $class";
    if ($prefix ne 'db') {
        isa_ok $uri->uri, 'URI::_db';
        isa_ok $uri->uri, $class;
    }
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{Simple URI engine should be "$label"};
    is $uri->canonical_engine, $canon, qq{Simple URI canonical engine should be "$clabel"};
    is $uri->dbname, undef, 'Simple URI db name should be undef';
    is $uri->host, undef, 'Simple URI host should be undef';
    is $uri->port, $port, 'Simple URI port should be undef';
    is $uri->user, undef, 'Simple URI user should be undef';
    is $uri->password, undef, 'Simple URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Simple URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [], 'Simple URI query params should be empty';
    is $uri->as_string, "$prefix:", 'Simple URI string should be correct';
    is "$uri", "$prefix:", 'Simple URI should correctly strigify';

    if ($engine) {
        ok $uri->has_recognized_engine, "$engine should be recognized engine";
    } else {
        ok !$uri->has_recognized_engine, "$prefix should not be recognized engine";
    }

    isa_ok $uri = URI->new("$prefix:foo.db"), 'URI::db', "Path URI with $class";
    isa_ok $uri->uri, $class, "Path URI $class URI";
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{Path URI engine should be "$label"};
    is $uri->canonical_engine, $canon, qq{Path URI canonical engine should be "$clabel"};
    is $uri->dbname, 'foo.db', 'Path URI db name should be "foo.db"';
    is $uri->host, undef, 'Path URI host should be undef';
    is $uri->port, $port, 'Path URI port should be undef';
    is $uri->user, undef, 'Path URI user should be undef';
    is $uri->password, undef, 'Path URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Path URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [], 'Path URI query params should be empty';
    is $uri->as_string, "$prefix:foo.db", 'Path URI string should be correct';
    is "$uri", "$prefix:foo.db", 'Simple URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix:/path/to/foo.db"), 'URI::db',
        "Absolute Path URI with class";
    isa_ok $uri->uri, $class, "Absolute Path URI $class URI";
    isa_ok $uri, 'URI::db' unless $prefix eq 'db';
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{Absolute Path URI engine should be "$label"};
    is $uri->canonical_engine, $canon, qq{Absolute path URI canonical engine should be "$clabel"};
    is $uri->dbname, '/path/to/foo.db',
        'Absolute Path URI db name should be "/path/to/foo.db"';
    is $uri->host, undef, 'Absolute Path URI host should be undef';
    is $uri->port, $port, 'Absolute Path URI port should be undef';
    is $uri->user, undef, 'Absolute Path URI user should be undef';
    is $uri->password, undef, 'Absolute Path URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Absolute Path URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Absolute Path URI query params should be empty';
    is $uri->as_string, "$prefix:/path/to/foo.db",
        'Absolute Path URI string should be correct';
    is "$uri", "$prefix:/path/to/foo.db",
        'Simple URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix:///path/to/foo.db"), 'URI::db',
        "No host, full path URI with $class";
    isa_ok $uri->uri, $class, "No host, full path URI $class URI";
    isa_ok $uri, 'URI::db' unless $prefix eq 'db';
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{No host, full path URI engine should be "$label"};
    is $uri->canonical_engine, $canon, qq{No host, full path URI canonical engine should be "$clabel"};
    is $uri->dbname, 'path/to/foo.db',
        'No host, full path URI db name should be "path/to/foo.db"';
    is $uri->host, '', 'No host, full path URI host should be empty';
    is $uri->port, $port, 'No host, full path URI port should be undef';
    is $uri->user, undef, 'No host, full path URI user should be undef';
    is $uri->password, undef, 'No host, full path URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'No host, full path URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'No host, full path URI query params should be empty';
    is $uri->as_string, "$prefix:///path/to/foo.db",
        'No host, full path URI string should be correct';
    is "$uri", "$prefix:///path/to/foo.db",
        'Simple URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://"), 'URI::db', "Hostless URI with $class";
    isa_ok $uri->uri, $class, "Hostless URI $class URI";
    is $uri->engine, $engine, qq{Hostless URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Hostless URI canonical engine should be "$clabel"};
    is $uri->dbname, undef, 'Hostless URI db name should be undef';
    is $uri->host, '', 'Hostless URI host should be ""';
    is $uri->port, $port, 'Hostless URI port should be undef';
    is $uri->user, undef, 'Hostless URI user should be undef';
    is $uri->password, undef, 'Hostless URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Hostless URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Hostless URI query params should be empty';
    is $uri->as_string, "$prefix://", 'Hostless URI string should be correct';
    is "$uri", "$prefix://", 'Hostless URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://localhost//foo.db"), 'URI::db',
        "Host+FullPath URI with $class";
    isa_ok $uri->uri, $class, "Host+FullPath URI $class URI";
    is $uri->engine, $engine, qq{Host+FullPath URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Host+FullPath URI canonical engine should be "$clabel"};
    is $uri->dbname, '/foo.db', 'Host+FullPath URI db name should be "/foo.db"';
    is $uri->host, 'localhost', 'Host+FullPath URI host should be "localhost"';
    is $uri->port, $port, 'Host+FullPath URI port should be undef';
    is $uri->user, undef, 'Host+FullPath URI user should be undef';
    is $uri->password, undef, 'Host+FullPath URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Host+FullPath URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Host+FullPath URI query params should be empty';
    is $uri->as_string, "$prefix://localhost//foo.db",
        'Host+FullPath URI string should be correct';
    is "$uri", "$prefix://localhost//foo.db",
        'Host+FullPath URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://localhost/%2Ftmp/test.gdb"), 'URI::db',
        "Host+PcntPath URI with $class";
    isa_ok $uri->uri, $class, "Host+PcntPath URI $class URI";
    is $uri->engine, $engine, qq{Host+PcntPath URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Host+PcntPath URI canonical engine should be "$clabel"};
    is $uri->dbname, '/tmp/test.gdb', 'Host+PcntPath URI db name should be "/tmp/test.gdb"';
    is $uri->host, 'localhost', 'Host+PcntPath URI host should be "localhost"';
    is $uri->port, $port, 'Host+PcntPath URI port should be undef';
    is $uri->user, undef, 'Host+PcntPath URI user should be undef';
    is $uri->password, undef, 'Host+PcntPath URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Host+PcntPath URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Host+PcntPath URI query params should be empty';
    is $uri->as_string, "$prefix://localhost/%2Ftmp/test.gdb",
        'Host+PcntPath URI string should be correct';
    is "$uri", "$prefix://localhost/%2Ftmp/test.gdb",
        'Host+PcntPath URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://localhost/C:/tmp/foo.db"), 'URI::db',
        "Host+WinPath URI with $class";
    isa_ok $uri->uri, $class, "Host+WinPath URI $class URI";
    is $uri->engine, $engine, qq{Host+WinPath URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Host+WinPath URI canonical engine should be "$clabel"};
    is $uri->dbname, 'C:/tmp/foo.db', 'Host+WinPath URI db name should be "C:/tmp/foo.db"';
    is $uri->host, 'localhost', 'Host+WinPath URI host should be "localhost"';
    is $uri->port, $port, 'Host+WinPath URI port should be undef';
    is $uri->user, undef, 'Host+WinPath URI user should be undef';
    is $uri->password, undef, 'Host+WinPath URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Host+WinPath URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Host+WinPath URI query params should be empty';
    is $uri->as_string, "$prefix://localhost/C:/tmp/foo.db",
        'Host+WinPath URI string should be correct';
    is "$uri", "$prefix://localhost/C:/tmp/foo.db",
        'Host+WinPath URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix:////foo.db"), 'URI::db',
        "Hostless+FullPath URI with $class";
    isa_ok $uri->uri, $class, "Hostless+FullPath URI $class URI";
    is $uri->engine, $engine, qq{Hostless+FullPath URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Hostless+FullPath URI canonical engine should be "$clabel"};
    is $uri->dbname, '/foo.db', 'Hostless+FullPath URI db name should be "/foo.db"';
    is $uri->host, '', 'Hostless+FullPath URI host should be ""';
    is $uri->port, $port, 'Hostless+FullPath URI port should be undef';
    is $uri->user, undef, 'Hostless+FullPath URI user should be undef';
    is $uri->password, undef, 'Hostless+FullPath URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Hostless+FullPath URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Hostless+FullPath URI query params should be empty';
    is $uri->as_string, "$prefix:////foo.db",
        'Hostless+FullPath URI string should be correct';
    is "$uri", "$prefix:////foo.db",
        'Hostless+FullPath URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://localhost"), 'URI::db', "Localhost URI with $class";
    isa_ok $uri->uri, $class, "Localhost URI $class URI";
    is $uri->engine, $engine, qq{Localhost URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Localhost URI canonical engine should be "$clabel"};
    is $uri->dbname, undef, 'Localhost URI db name should be undef';
    is $uri->host, 'localhost', 'Localhost URI host should be "localhost"';
    is $uri->port, $port, 'Localhost URI port should be undef';
    is $uri->user, undef, 'Localhost URI user should be undef';
    is $uri->password, undef, 'Localhost URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Localhost URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Localhost URI query params should be empty';
    is $uri->as_string, "$prefix://localhost",
        'Localhost URI string should be correct';
    is "$uri", "$prefix://localhost",
        'Localhost URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://example.com:5433"), 'URI::db',
        "Host+Port DB URI with $class";
    isa_ok $uri->uri, $class, "Host+Port URI $class URI";
    is $uri->engine, $engine, qq{Host+Port URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Host+Port URI canonical engine should be "$clabel"};
    is $uri->dbname, undef, 'Host+Port URI db name should be undef';
    is $uri->host, 'example.com', 'Host+Port URI host should be "example.com"';
    is $uri->port, 5433, 'Host+Port URI port should be 5433';
    is $uri->user, undef, 'Host+Port URI user should be undef';
    is $uri->password, undef, 'Host+Port URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Host+Port URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Host+Port URI query params should be empty';
    is $uri->as_string, "$prefix://example.com:5433",
        'Host+Port URI string should be correct';
    is "$uri", "$prefix://example.com:5433",
        'Host+Port URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://example.com/mydb"), 'URI::db',
        "DB URI with $class";
    isa_ok $uri->uri, $class, "DB URI $class URI";
    is $uri->engine, $engine, qq{DB URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{DB URI canonical engine should be "$clabel"};
    is $uri->dbname, 'mydb', 'DB URI db name should be "mydb"';
    is $uri->host, 'example.com', 'DB URI host should be "example.com"';
    is $uri->port, $port, 'DB URI port should be undef';
    is $uri->user, undef, 'DB URI user should be undef';
    is $uri->password, undef, 'DB URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'DB URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'DB URI query params should be empty';
    is $uri->as_string, "$prefix://example.com/mydb",
        'DB URI string should be correct';
    is "$uri", "$prefix://example.com/mydb",
        'DB URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://example.com/"), 'URI::db',
        "DBLess URI with $class";
    isa_ok $uri->uri, $class, "DBLess URI $class URI";
    is $uri->engine, $engine, qq{DBless URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{DBless URI canonical engine should be "$clabel"};
    is $uri->dbname, '', 'DBless URI db name should be ""';
    is $uri->host, 'example.com', 'DBless URI host should be "example.com"';
    is $uri->port, $port, 'DBless URI port should be undef';
    is $uri->user, undef, 'DBless URI user should be undef';
    is $uri->password, undef, 'DBless URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'DBless URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'DBless URI query params should be empty';
    is $uri->as_string, "$prefix://example.com/",
        'DBless URI string should be correct';
    is "$uri", "$prefix://example.com/",
        'DBless URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://user\@localhost//fullpathdb"), 'URI::db',
        "User URI with $class";
    isa_ok $uri->uri, $class, "User URI $class URI";
    is $uri->engine, $engine, qq{User URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{User URI canonical engine should be "$clabel"};
    is $uri->dbname, '/fullpathdb', 'User URI db name should be "/fullpathdb"';
    is $uri->host, 'localhost', 'User URI host should be "localhost"';
    is $uri->port, $port, 'User URI port should be undef';
    is $uri->user, 'user', 'User URI user should be "user"';
    is $uri->password, undef, 'User URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'User URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'User URI query params should be empty';
    is $uri->as_string, "$prefix://user\@localhost//fullpathdb",
        'User URI string should be correct';
    is "$uri", "$prefix://user\@localhost//fullpathdb",
        'User URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://user\@//fullpathdb"), 'URI::db',
        "User w/o host URI with $class";
    isa_ok $uri->uri, $class, "User w/o host URI $class URI";
    is $uri->engine, $engine, qq{User w/o host URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{User w/o host URI canonical engine should be "$clabel"};
    is $uri->dbname, '/fullpathdb', 'User w/o host URI db name should be "/fullpathdb"';
    is $uri->host, '', 'User w/o host URI host should be ""';
    is $uri->port, $port, 'User w/o host URI port should be undef';
    is $uri->user, 'user', 'User w/o host URI user should be "user"';
    is $uri->password, undef, 'User w/o host URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'User w/o host URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'User w/o host URI query params should be empty';
    is $uri->as_string, "$prefix://user\@//fullpathdb",
        'User w/o host URI string should be correct';
    is "$uri", "$prefix://user\@//fullpathdb",
        'User w/o host URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://user:secret\@localhost"), 'URI::db',
        "Password URI with $class";
    isa_ok $uri->uri, $class, "Password URI $class URI";
    is $uri->engine, $engine, qq{Password URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Password URI canonical engine should be "$clabel"};
    is $uri->dbname, undef, 'Password URI db name should be undef';
    is $uri->host, 'localhost', 'Password URI host should be "localhost"';
    is $uri->port, $port, 'Password URI port should be undef';
    is $uri->user, 'user', 'Password URI user should be "user"';
    is $uri->password, 'secret', 'Password URI password should be "secret"';
    is_deeply $uri->query_form_hash, {},
        'Password URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Password URI query params should be empty';
    is $uri->as_string, "$prefix://user:secret\@localhost",
        'Password URI string should be correct';
    is "$uri", "$prefix://user:secret\@localhost",
        'Password URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://other\@localhost/otherdb?foo=bar&foo=baz&baz=yow"),
        'URI::db', "Query URI with $class";
    isa_ok $uri->uri, $class, "Query URI $class URI";
    is $uri->engine, $engine, qq{Query URI engine should be "label"};
    is $uri->canonical_engine, $canon, qq{Query URI canonical engine should be "$clabel"};
    is $uri->dbname, 'otherdb', 'Query URI db name should be "otherdb"';
    is $uri->host, 'localhost', 'Query URI host should be "localhost"';
    is $uri->port, $port, 'Query URI port should be undef';
    is $uri->user, 'other', 'Query URI user should be "other"';
    is $uri->password, undef, 'Query URI password should be undef';
    is_deeply $uri->query_form_hash, { foo => [qw(bar baz)], baz => 'yow'},
        'Query URI query params should be populated';
    is_deeply [ $uri->query_params ], [ foo => 'bar', foo => 'baz', baz => 'yow' ],
        'query URI query params should be populated';
    is $uri->as_string, "$prefix://other\@localhost/otherdb?foo=bar&foo=baz&baz=yow",
        'Query URI string should be correct';
    is "$uri", "$prefix://other\@localhost/otherdb?foo=bar&foo=baz&baz=yow",
        'Query URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix:foo.db#foo.bar"), 'URI::db', "Fragment URI with $class";
    isa_ok $uri->uri, $class, "Fragment URI $class URI";
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{Fragment URI engine should be "$label"};
    is $uri->canonical_engine, $canon, qq{Frgement URI canonical engine should be "$clabel"};
    is $uri->dbname, 'foo.db', 'Fragment URI db name should be "foo.db"';
    is $uri->host, undef, 'Fragment URI host should be undef';
    is $uri->port, $port, 'Fragment URI port should be undef';
    is $uri->user, undef, 'Fragment URI user should be undef';
    is $uri->password, undef, 'Fragment URI password should be undef';
    is $uri->fragment, 'foo.bar', 'Fragement URI fragment should be "foo.bar"';
    is_deeply $uri->query_form_hash, {},
        'Fragment URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [], 'Fragment URI query params should be empty';
    is $uri->as_string, "$prefix:foo.db#foo.bar", 'Fragment URI string should be correct';
    is "$uri", "$prefix:foo.db#foo.bar", 'Simple URI should correctly strigify';
}

done_testing;
