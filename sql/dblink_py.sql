CREATE EXTENSION dblink_py;

SELECT extname,extrelocatable,extversion FROM pg_extension WHERE extname = 'dblink_py';

SELECT dblink_get_connections();

-- 'postgresql://{username}:{password}@{hostname}:{port}/{database}'
SELECT dblink_connect('foo', 'postgresql://localhost/postgres');
SELECT dblink_get_connections();

SELECT dblink_connect('bar', 'postgresql://localhost/nosuchdb');
SELECT dblink_get_connections();

SELECT dblink_disconnect('bar');
SELECT dblink_get_connections();

SELECT dblink_disconnect('foo');
SELECT dblink_get_connections();


SELECT dblink_connect('foo', 'postgresql://localhost/' || current_database());
-- dblink_open()/dblink_close()

SELECT dblink_open('foo', 'bar', 'select * from pg_language', false);
SELECT dblink_close('foo', 'bar', true);

SELECT dblink_open('foo', 'bar', 'select * from nosuchtable', false);
SELECT dblink_close('foo', 'bar', false);

SELECT dblink_open('foo', 'bar', 'select * from nosuchtable', true);
SELECT dblink_close('foo', 'bar', true);

-- dblink_fetch()
SELECT dblink_open('foo', 'bar', 'select lanname,lanispl from pg_language order by oid', true);

SELECT * FROM dblink_fetch('foo', 'bar', 2, false) AS (lanname name, lanispl boolean);
SELECT * FROM dblink_fetch('foo', 'bar', 2, false) AS (lanname name, lanispl boolean);
SELECT * FROM dblink_fetch('foo', 'bar', 2, false) AS (lanname name, lanispl boolean);

-- error
SELECT * FROM dblink_fetch('foo', 'bar2', 2, false) AS (lanname name, lanispl boolean);

-- error
SELECT * FROM dblink_fetch('foo', 'bar2', 2, true) AS (lanname name, lanispl boolean);

SELECT dblink_close('foo', 'bar', true);

SELECT dblink_disconnect('foo');

SELECT * FROM
  dblink('postgresql://localhost/' || current_database(),
         'select lanname,lanispl from pg_language',
         true)
    AS (lanname name, lanispl boolean);

SELECT dblink_exec('postgresql://localhost/' || current_database(), 'CREATE TABLE temp_temp AS SELECT * FROM pg_language', true);

SELECT dblink_exec('postgresql://localhost/' || current_database(), 'CREATE TABLE temp_temp AS SELECT * FROM pg_language', false);

DROP EXTENSION dblink_py;
