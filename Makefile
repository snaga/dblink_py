# contrib/dblink_py/Makefile

#MODULE_big = dblink_py
#OBJS	= dblink.o $(WIN32RES)
PG_CPPFLAGS = -I$(libpq_srcdir)
SHLIB_LINK_INTERNAL = $(libpq)

EXTENSION = dblink_py
DATA = dblink_py--0.1.sql
PGFILEDESC = "dblink_py - connect to other PostgreSQL databases"

REGRESS = dblink_py
REGRESS_OPTS = --dlpath=$(top_builddir)/src/test/regress

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
SHLIB_PREREQS = submake-libpq
subdir = contrib/dblink
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
