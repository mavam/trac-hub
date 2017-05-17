#!/bin/sh
#
# This is a helper shell script to extract all attachment files from a 
# working trac installation and store it into a dedicated directory which
# can then be put onto some webspace and the --attachment-url option being using
# with trac-hub to reference these files in attachment comments to tickets
#
# Copyright 2016 (c) Jens Maus <mail@jens-maus.de>
#
# This script connects to an `sqlite` database and directly exports the files
# using `trac-admin`. If you don't have access to `trac-admin` or use a MySQL
# database, take a look at the `download-trac-attachments-mysql.sh` script.

TRAC_ENV=/var/www/www.yam.ch/trac
TRAC_DB=${TRAC_ENV}/db/trac.db
OUTPUT_DIR=/tmp/trac

if [ "$USER" != "root" ]; then
 echo "ERROR: script has to be run as super-user (sudo)"
 exit 2
fi

# get all ids and filename of all attachments
output=$(sqlite3 ${TRAC_DB} "select id,filename from attachment where type='ticket';")

# make sure the output dir is clean
rm -rf ${OUTPUT_DIR}

# walk through the output
IFS=$'\n'
for line in ${output}; do
  ticket=$(echo $line | cut -d '|' -f 1)
  file=$(echo $line | cut -d '|' -f 2)

  mkdir -p ${OUTPUT_DIR}/${ticket}
  echo -n "Saving attachments of ticket #${ticket}... "
  trac-admin ${TRAC_ENV} attachment export ticket:${ticket} "${file}" ${OUTPUT_DIR}/${ticket} 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "ERROR!"
  fi
  echo "done."
done
