#!/bin/bash

DATE=$(date +"%Y-%m-%d-%H-%M")
PG_BASEBACKUP=pg_basebackup
PSQL=psql
BZIP2=bzip2
MKDIR=mkdir

###########################
####### LOAD CONFIG #######
###########################
while [ $# -gt 0 ]; do
  case $1 in
    -c)
      CONFIG_FILE_PATH="$2"
      shift 2
      ;;
    *)
      ${ECHO} "Unknown Option \"$1\"" 1>&2
      exit 2
      ;;
  esac
done

if [ -z $CONFIG_FILE_PATH ] ; then
  SCRIPTPATH=$(cd ${0%/*} && pwd -P)
  CONFIG_FILE_PATH="${SCRIPTPATH}/pg_backup.config"
fi

if [ ! -r ${CONFIG_FILE_PATH} ] ; then
  echo "Could not load config file from ${CONFIG_FILE_PATH}" 1>&2
  exit 1
fi

source "${CONFIG_FILE_PATH}"

DUMPLOG="$BACKUP_DIR/pg_basebackup-${DATE}.log"
DUMPDIR="$BACKUP_DIR/pg_basebackup-${DATE}"

###########################
#### PRE-BACKUP CHECKS ####
###########################

# Make sure we're running as the required backup user
if [ "$BACKUP_USER" != "" -a "$(id -un)" != "$BACKUP_USER" ] ; then
  echo "This script must be run as $BACKUP_USER. Exiting." 1>&2
  exit 1
fi

# Check if we can connect to postgres
$PSQL --tuples-only --quiet -h $HOSTNAME -U $USERNAME -p $PORT -c ''
RETVAL=$?

if [ $RETVAL != 0 ]; then
  echo "PostgreSQL DB not running"
  exit $RETVAL
else
  echo "PostgreSQL DB is running"
fi

# Check that the BACKUP_DIR directory Exists 
if [ ! -d $BACKUP_DIR ]; then
  echo "No Dump Directory: ${BACKUP_DIR}"
  exit 1
fi

# Check that the DATADIR directory Exists 
if [ ! -d $DATADIR ]; then
  echo "No Data Directory: ${DATADIR}"
  exit 1
fi

###########################
#### START THE BACKUPS ####
###########################

# Start Physical DB backup
echo "Start ${DATE}" > $DUMPLOG

cd $DATADIR
if [ $? != 0 ]; then
  echo "Could not cd to $DATADIR"
  exit $RETVAL
fi

$MKDIR $DUMPDIR
if [ $? != 0 ]; then
  echo "Could not create directory $DATADIR"
  exit $RETVAL
fi


unset RETVAL
$PG_BASEBACKUP -D $DUMPDIR -h $HOSTNAME -p $PORT -U $USERNAME -Fp -X stream
RETVAL=$?

if [ $RETVAL != 0 ]; then
  echo "${DATE}: Backup failed"
  exit $RETVAL
else 
  echo "${DATE}: Backup successful"
fi
