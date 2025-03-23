#!/bin/bash

# Arguments for the script (passed from the main script)
DSTHOST="$1"
DSTSSHPORT="$2"
DSTUSER="$3"
DSTDBNAME="$4"
DSTDBUSER="$5"
DSTDBPASS="$6"
DSTHOME="$7"
DB_DUMP_NAME="$8"

DB_TYPE="$9"  # Added argument for DB_TYPE to determine the database type (mysql, mariadb, postgresql)

# Function to restore MySQL/MariaDB database
restore_mysql() {
    if [ "$DSTHOST" = "localhost" ] || [ "$DSTHOST" = "127.0.0.1" ]; then
        # Local restore without SSH
        mysql -u $DSTDBUSER -p"$DSTDBPASS" $DSTDBNAME < $DSTHOME/${DB_DUMP_NAME}
    else
        # Remote destination, local source (using SSH for remote destination)
        ssh -p $DSTSSHPORT $DSTUSER@$DSTHOST "mysql -u $DSTDBUSER -p\"$DSTDBPASS\" $DSTDBNAME < $DSTHOME/${DB_DUMP_NAME}"
    fi
}

# Function to restore PostgreSQL database
restore_postgresql() {
    if [ "$DSTHOST" = "localhost" ] || [ "$DSTHOST" = "127.0.0.1" ]; then
        # Local restore for PostgreSQL
        PGPASSWORD=$DSTDBPASS psql -U $DSTDBUSER $DSTDBNAME < $DSTHOME/${DB_DUMP_NAME}
    else
        # Remote restore with SSH (using SSH for remote destination)
        ssh -p $DSTSSHPORT $DSTUSER@$DSTHOST "PGPASSWORD=$DSTDBPASS psql -U $DSTDBUSER $DSTDBNAME < $DSTHOME/${DB_DUMP_NAME}"
    fi
}

# Determine which database to restore
case "$DB_TYPE" in
    mysql|mariadb)
        restore_mysql
        ;;
    postgresql)
        restore_postgresql
        ;;
    *)
        echo "Unsupported database type: $DB_TYPE"
        exit 1
        ;;
