#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 {file}"
  exit 1
fi

FILE="$1"
CHANGETEXT=$2
ss
NAME=$(basename "$FILE")
EXT=$(echo "$NAME" | cut -d'.' -f2) # txt or log 
BASE=$(echo "$NAME" | cut -d'.' -f1) # file name 
NEWNAME="${BASE}_renamed_${CHANGETEXT}.${EXT}"
DIR=$(dirname "$FILE")
mv "$FILE" "$DIR/$NEWNAME"

echo "Renamed:"
echo "Old: $FILE"
echo "New: $DIR/$NEWNAME"