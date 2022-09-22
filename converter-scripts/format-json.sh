#!/bin/bash
#
# FORMAT JSON
#
# 3n3a
#

file=$1

if [[ -z $file ]]; then
    echo "Please enter a filename."
    exit 1
fi

cat $file | jq > /tmp/temp.json
mv /tmp/temp.json $file
