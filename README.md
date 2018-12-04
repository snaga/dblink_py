
# dblink/py

dblink/py is yet another dblink implementation with PL/Python. It is
designed to be simple, small and extensible.

dblink/py is a subset of [the dblink contrib
module](https://www.postgresql.org/docs/current/dblink.html) in the
core.

## Requirements

* PostgreSQL
* PL/Python
* psycopg2

## Supported DBMSes

* PostgreSQL
* SQLite

## Supported Functions

* dblink_connect()
* dblink_disconnect()
* dblink_get_connections()
* dblink_open()
* dblink_fetch()
* dblink_close()
* dblink()
* dblink_exec()

For more details, please take a look at those regression tests in
`sql/dblink_py.sql` and `sql/dblink_py_sqlite.sql`.

## Installation

```
git clone https://github.com/snaga/dblink_py.git
cd dblink_py
env USE_PGXS=1 make install
createdb testdb
psql testdb
create extension plpython2u;
create extension dblink_py;
```

## Author

Satoshi Nagayasu \<snaga \_at\_ uptime \_dot\_ jp\>


EOF
