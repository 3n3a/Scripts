#!/bin/bash
#
# Replace all the öüü in Filenames.
#   by 3n3a
#

if [ $# -eq 0 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

directory="$1"

if rename -V 2>&1 | grep -q "util-linux"; then
  echo "Using util-linux rename"
else
  echo "Rename utility is not from util-linux"
  exit 1
fi

find "$directory" -type f -exec rename -v 'ä' 'a' {} + -exec rename -v 'ü' 'u' {} + -exec rename -v 'ö' 'o' {} +
