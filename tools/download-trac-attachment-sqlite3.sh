#!/bin/sh
#
# This is a helper shell script to download all attachment files from a
# working trac server and store it into a dedicated directory which can then
# be put onto some webspace and the --attachment-url option being using with
# trac-hub to reference these files in attachment comments to tickets.
#
# This script connects to a `sqlite3` database and downloads the files from
# using `wget`.

OUTPUT_DIR=/tmp/trac
TRAC_URL=https://your-site.com/project/trac
DB_PATH=/mnt/trac.db

# get all ids and filename of all attachments
# output=$(sqlite3 ${DB_PATH} "select a.id, a.filename from ticket t, attachment a where t.status != 'closed' and a.type='ticket' and t.id=a.id;")
output=$(sqlite3 ${DB_PATH} "select a.id, a.filename from ticket t, attachment a where a.type='ticket' and t.id=a.id;")

# make sure the output dir is clean
# rm -rf ${OUTPUT_DIR}


# walk through the output
IFS=$'\n'
for line in ${output}; do
  ticket=$(echo $line | cut -d '|' -f 1)
  file=$(echo $line | cut -d '|' -f 2-)
  if [ "$ticket" = "id" ]; then
    continue
  fi

  echo -n "Saving attachments of ticket #${ticket}... "
  mkdir -p "${OUTPUT_DIR}/${ticket}"

  if wget "$TRAC_URL/raw-attachment/ticket/${ticket}/${file}" --output-document "${OUTPUT_DIR}/${ticket}/${file}" --quiet; then
    echo "done."
  else
    echo "$TRAC_URL/raw-attachment/ticket/${ticket}/${file}"
    echo "ERROR!"
  fi
done
