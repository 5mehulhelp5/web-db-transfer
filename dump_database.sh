#!/bin/bash

# Arguments for the script (passed from the main(transfer.sh) script)
SRCHOST="$1"
SRCSSHPORT="$2"
SRCUSER="$3"
SRCDBNAME="$4"
SRCDBUSER="$5"
SRCDBPASS="$6"
SRCHOME="$7"
DB_DUMP_NAME="$8"

DB_TYPE="$9"  # Added argument for DB_TYPE to determine the database type (mysql, mariadb, postgresql)

# Function to dump MySQL/MariaDB database
dump_mysql() {
    if [ "$SRCHOST" = "localhost" ] || [ "$SRCHOST" = "127.0.0.1" ]; then
        # Local MySQL dump without SSH
        mysqldump --no-tablespaces -u $SRCDBUSER -p"$SRCDBPASS" $SRCDBNAME > $SRCHOME/${DB_DUMP_NAME}
    else
        # Remote MySQL dump with SSH
        ssh -p $SRCSSHPORT $SRCUSER@$SRCHOST "mysqldump --no-tablespaces -u $SRCDBUSER -p\"$SRCDBPASS\" $SRCDBNAME > $SRCHOME/${DB_DUMP_NAME}"
    fi
}

# Function to dump PostgreSQL database
dump_postgresql() {
    if [ "$SRCHOST" = "localhost" ] || [ "$SRCHOST" = "127.0.0.1" ]; then
        # Local PostgreSQL dump
        PGPASSWORD=$SRCDBPASS pg_dump -U $SRCDBUSER -F c $SRCDBNAME > $SRCHOME/${DB_DUMP_NAME}
    else
        # Remote PostgreSQL dump with SSH
        ssh -p $SRCSSHPORT $SRCUSER@$SRCHOST "PGPASSWORD=$SRCDBPASS pg_dump -U $SRCDBUSER -F c $SRCDBNAME > $SRCHOME/${DB_DUMP_NAME}"
    fi
}

# Determine which database to dump
case "$DB_TYPE" in
    mysql|mariadb)
        dump_mysql
        ;;
    postgresql)
        dump_postgresql
        ;;
    *)
        echo "Unsupported database type: $DB_TYPE"
        exit 1
        ;;
esac
