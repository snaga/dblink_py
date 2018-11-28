/* contrib/dblink_py/dblink_py--0.1.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION dblink_py" to load this file. \quit

CREATE FUNCTION dblink_connect(connname text, connstr text) RETURNS text
AS
$$
    import psycopg2
    import sqlite3

    if 'connections' not in GD or not isinstance(GD['connections'], dict):
        GD['connections'] = {}
    conn = None
    if connstr.startswith('postgresql://'):
        conn = psycopg2.connect(connstr)
    elif connstr.startswith('sqlite://'):
        conn = sqlite3.connect(connstr[9:])
    else:
        raise Exception("Could not handle a connection string '{0}'.".format(connstr))
    GD['connections'][connname] = conn
    return 'OK'
$$
LANGUAGE 'plpython2u';

CREATE FUNCTION dblink(connstr text, sql text, fail_on_error bool) RETURNS setof record
AS
$$
    import psycopg2
    import sqlite3

    conn = None
    if connstr.startswith('postgresql://'):
        conn = psycopg2.connect(connstr)
    elif connstr.startswith('sqlite://'):
        conn = sqlite3.connect(connstr[9:])
    else:
        raise Exception("Could not handle a connection string '{0}'.".format(connstr))

    cursorname = '__noname__'
    try:
        cur = conn.cursor(cursorname)
    except TypeError as ex:
        cur = conn.cursor()

    try:
        cur.execute(sql)
        for r in cur.fetchall():
	    yield r
    except Exception as ex:
        if fail_on_error:
     	    raise ex
        else:
	    plpy.notice(str(ex))
	    return
    cur.close()
    conn.close()
$$
LANGUAGE 'plpython2u';

CREATE FUNCTION dblink_exec(connstr text, sql text, fail_on_error bool) RETURNS text
AS
$$
    import psycopg2
    import sqlite3

    conn = None
    if connstr.startswith('postgresql://'):
        conn = psycopg2.connect(connstr)
    elif connstr.startswith('sqlite://'):
        conn = sqlite3.connect(connstr[9:])
    else:
        raise Exception("Could not handle a connection string '{0}'.".format(connstr))

    cur = conn.cursor()
    status = None
    try:
        r = cur.execute(sql)
	conn.commit()
        try:
            status = cur.statusmessage
        except AttributeError as ex:
            status = 'OK'
    except Exception as ex:
        if fail_on_error:
     	    raise ex
        else:
	    plpy.notice(str(ex))
	    status = 'ERROR'

    cur.close()
    conn.close()

    return status
$$
LANGUAGE 'plpython2u';

CREATE FUNCTION dblink_disconnect(connname text) RETURNS text
AS
$$
    conn = GD['connections'][connname]
    conn.close()
    del GD['connections'][connname]
    return 'OK'
$$
LANGUAGE 'plpython2u';

CREATE FUNCTION dblink_get_connections() RETURNS text[]
AS
$$
    if 'connections' not in GD or not isinstance(GD['connections'], dict):
        GD['connections'] = {}
    return GD['connections'].keys()
$$
LANGUAGE 'plpython2u';

CREATE FUNCTION dblink_open(connname text, cursorname text, sql text, fail_on_error bool) RETURNS TEXT
AS
$$
    import plpy
    conn = GD['connections'][connname]

    if 'cursors' not in GD or not isinstance(GD['cursors'], dict):
        GD['cursors'] = {}
    try:
        GD['cursors'][cursorname] = conn.cursor(cursorname)
    except TypeError as ex:
        GD['cursors'][cursorname] = conn.cursor()

    try:
        GD['cursors'][cursorname].execute(sql)
    except Exception as ex:
        GD['cursors'][cursorname].connection.rollback()
        if fail_on_error:
	    raise ex
        else:
	    plpy.notice(str(ex))
	    return 'ERROR'
    return 'OK'
$$
LANGUAGE 'plpython2u';

CREATE FUNCTION dblink_fetch(connname text, cursorname text, howmany int, fail_on_error bool) RETURNS SETOF RECORD
AS
$$
    try:
        for r in GD['cursors'][cursorname].fetchmany(howmany):
	   yield r
    except Exception as ex:
        if fail_on_error:
     	    raise ex
        else:
	    plpy.notice(str(ex))
	    return
$$
LANGUAGE 'plpython2u';

CREATE FUNCTION dblink_close(connname text, cursorname text, fail_on_error bool) RETURNS TEXT
AS
$$
    try:
        GD['cursors'][cursorname].close()
    except Exception as ex:
        GD['cursors'][cursorname].connection.rollback()
    	del GD['cursors'][cursorname]
        if fail_on_error:
	    raise ex
        else:
	    plpy.notice(str(ex))
	    return 'ERROR'
    return 'OK'
$$
LANGUAGE 'plpython2u';
