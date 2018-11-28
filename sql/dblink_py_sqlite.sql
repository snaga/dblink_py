CREATE EXTENSION dblink_py;

SELECT extname,extrelocatable,extversion FROM pg_extension WHERE extname = 'dblink_py';

-- 'sqlite://{filepath}'

-- dblink_exec()/dblink()
SELECT dblink_exec('sqlite:///tmp/dblink_py.db',
                   'DROP TABLE IF EXISTS t1',
                   true);

SELECT dblink_exec('sqlite:///tmp/dblink_py.db',
                   'CREATE TABLE t1 ( user_id integer, user_name text)',
                   true);

-- exception
SELECT dblink_exec('sqlite:///tmp/dblink_py.db',
                   'CREATE TABLE t1 ( user_id integer, user_name text)',
                   true);

-- error
SELECT dblink_exec('sqlite:///tmp/dblink_py.db',
                   'CREATE TABLE t1 ( user_id integer, user_name text)',
                   false);

SELECT dblink_exec('sqlite:///tmp/dblink_py.db',
                   'INSERT INTO t1 VALUES (1,''1''),(2,''2''),(3,''3''),(4,''4''),(5,''5'')',
                   false);

SELECT * FROM
  dblink('sqlite:///tmp/dblink_py.db', 'select * from t1', true)
    AS (user_id integer, user_name text);


-- dblink_get_connection()/dblink_connect()/dblink_disconnect()
SELECT dblink_get_connections();

SELECT dblink_connect('foo', 'sqlite:///tmp/dblink_py.db');
SELECT dblink_get_connections();

SELECT dblink_disconnect('bar');
SELECT dblink_get_connections();

SELECT dblink_disconnect('foo');
SELECT dblink_get_connections();


SELECT dblink_connect('foo', 'sqlite:///tmp/dblink_py.db');
-- dblink_open()/dblink_close()

SELECT dblink_open('foo', 'bar', 'select * from sqlite_master', false);
SELECT dblink_close('foo', 'bar', true);

SELECT dblink_open('foo', 'bar', 'select * from nosuchtable', false);
SELECT dblink_close('foo', 'bar', false);

SELECT dblink_open('foo', 'bar', 'select * from nosuchtable', true);
SELECT dblink_close('foo', 'bar', true);

-- dblink_fetch()
SELECT dblink_open('foo', 'bar', 'select user_id,user_name from t1 order by 1', true);

SELECT * FROM dblink_fetch('foo', 'bar', 2, false) AS (user_id integer, user_name text);
SELECT * FROM dblink_fetch('foo', 'bar', 2, false) AS (user_id integer, user_name text);
SELECT * FROM dblink_fetch('foo', 'bar', 2, false) AS (user_id integer, user_name text);

-- error
SELECT * FROM dblink_fetch('foo', 'bar2', 2, false) AS (user_id integer, user_name text);

-- error
SELECT * FROM dblink_fetch('foo', 'bar2', 2, true) AS (user_id integer, user_name text);

SELECT dblink_close('foo', 'bar', true);

SELECT dblink_disconnect('foo');

DROP EXTENSION dblink_py;
