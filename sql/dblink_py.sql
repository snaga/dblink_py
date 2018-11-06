CREATE EXTENSION dblink_py;

SELECT extname,extrelocatable,extversion FROM pg_extension WHERE extname = 'dblink_py';

DROP EXTENSION dblink_py;
