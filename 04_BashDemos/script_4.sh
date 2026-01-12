#!/bin/bash

# required exactly onr param
if [ $# -ne 1 ]; then
  echo "Usage: $0 folder-path"
  exit 1
fi

# incoming param
DIR=$1
# current date
DATE= $(date +"%Y_%m_%d_%H_%M")
# combined gz file name
OUT="backup_`basename $DIR`_${DATE}.tar.gz"
#execute zip
tar -czvf "$OUT" "$DIR"

echo "Created: $OUT"
ls -l $OUT


