#!/bin/sh
#
# This is a helper shell script to download all attachment files from a
# working trac server and store it into a dedicated directory which can then
# be put onto some webspace and the --attachment-url option being using with
# trac-hub to reference these files in attachment comments to tickets.
#
# This script connects to a `mysql` database and downloads the files from
# using `trac-admin`. If you use a `sqlite` database or have access to
# `trac-admin`, take a look at the `extract-trac-attachments.sh` script.

OUTPUT_DIR=/tmp/trac
TRAC_URL=https://your-site.com/project/trac

# get all ids and filename of all attachments
output=$(mysql -h HOST --port PORT -u USER --password=PASSWORD DATABASE
         -e "select id,filename from attachment where type='ticket';")

# make sure the output dir is clean
rm -rf ${OUTPUT_DIR}


# walk through the output
IFS=$'\n'
for line in ${output}; do
  ticket=$(echo $line | cut -d $'\t' -f 1)
  file=$(echo $line | cut -d $'\t' -f 2-)
  if [[ $ticket == id ]]; then
    continue
  fi

  mkdir -p ${OUTPUT_DIR}/${ticket}
  echo -n "Saving attachments of ticket #${ticket}... "
  mkdir -p "${OUTPUT_DIR}/${ticket}"

  if wget "$TRAC_URL/raw-attachment/ticket/${ticket}/${file}" --output-document "${OUTPUT_DIR}/${ticket}/${file}" --quiet; then
    echo "done."
  else
    echo "ERROR!"
  fi
done
