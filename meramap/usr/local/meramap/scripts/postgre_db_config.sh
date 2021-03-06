#!/bin/bash
# NAME: postgr_db_gj.sh
# DESC: Creates a postgresql database and installs the postgis extension
#       to make it ready to accept openstreetmap data for rendering
#       using mapnik.
#       This script is part of MeraMap.
# HIST: 06 July 2011   Original Version by Parveen Arora
#       06 July 2011   Modified to work on multiple Ubuntu versions
#                       by Graham Jones.

source $MERAMAP_SCRIPT/variables.sh
if [ -e $MERAMAP/$LOGFILE ]; then rm $MERAMAP/$LOGFILE; fi

echo $0 >> $MERAMAP/$LOGFILE 2>&1

echo $DBNAME
echo $DBUSER
echo $UBUNTUVERSION

if [ $UBUNTUVERSION = "10.04" ]; then
    echo "Ubuntu Version 10.04 Detected"
    POSTGIS_SQL="/usr/share/postgresql/8.4/contrib/postgis.sql"
    SPATIAL_SQL="/usr/share/postgresql/8.4/contrib/spatial_ref_sys.sql"
    INT_SQL="/usr/share/postgresql/8.4/contrib/_int.sql"

elif [ $UBUNTUVERSION = "10.10" ]; then
    echo "Ubuntu Version 10.10 Detected"
    POSTGIS_SQL="/usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql"
    SPATIAL_SQL="/usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql"
    INT_SQL="/usr/share/postgresql/8.4/contrib/_int.sql"


elif [ $UBUNTUVERSION = "11.04" ]; then
    echo "Ubuntu Version 11.04 Detected"
    POSTGIS_SQL="/usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql"
    SPATIAL_SQL="/usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql"
    INT_SQL="/usr/share/postgresql/8.4/contrib/_int.sql"

else
    echo "ERROR - Ubuntu Version $UBUNTUVERSION is not supported"
    exit
fi

echo "Setting up database and user..."


dropdb $DBNAME >> $MERAMAP/$LOGFILE 2>&1
dropuser $DBUSER >> $MERAMAP/$LOGFILE 2>&1
createdb $DBNAME >> $MERAMAP/$LOGFILE 2>&1
createuser --no-createdb --no-superuser --no-createrole $DBUSER >> $MERAMAP/$LOGFILE 2>&1
createlang plpgsql $DBNAME; >> $MERAMAP/$LOGFILE 2>&1
psql -f $POSTGIS_SQL -d $DBNAME >> $MERAMAP/$LOGFILE 2>&1
psql -f $SPATIAL_SQL -d $DBNAME >> $MERAMAP/$LOGFILE  2>&1
psql -f $INT_SQL -d $DBNAME >> $MERAMAP/$LOGFILE 2>&1

echo "ALTER TABLE geometry_columns OWNER TO $DBUSER; ALTER TABLE spatial_ref_sys OWNER TO $DBUSER;" | psql -d $DBNAME >> $MERAMAP/$LOGFILE 2>&1
psql -f 900913.sql -d $DBNAME >> $MERAMAP/$LOGFILE 2>&1

echo "Done!"
