#!/bin/bash
# CHECK IF PARAMETER IS SENT  
if [[ $# -ne 1 ]]; then
    echo "Error: Exactly 1 parameter is required."
    exit 1
fi

# CHECK IF PARAMETER IS EMPTY OR NOT SET (USE -z)
USERNAME="$1"
if [[ -z "$USERNAME" ]]; then 
    echo "Error: Username is empty."
    exit 1
fi

# SET TRGET PATH FOR FOLDER
TARGET_DIR="./${USERNAME}"

# DELETE IF EXISTS , FOR MULTIPLE EXECUTIONS
if [[ -d "$TARGET_DIR" ]]; then
    echo "Directory '$TARGET_DIR' exists — deleting..."
    rm -r "$TARGET_DIR"
fi

#  CREATE DIRECTORY 
echo "Creating directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

# GENERATE 10 FILES USING WHILE 
echo "Generating 10 UUID files..."
COUNT=1
while [[ $COUNT -le 10 ]]; do
    UUID=$(uuidgen)
    FILE="${TARGET_DIR}/${UUID}.txt"
    echo "This is auto generated file $COUNT with UUID $UUID" > "$FILE"
    echo "Created: $FILE"
    ((COUNT++))
done

echo "Done! Files stored in: $TARGET_DIR"
echo "---------------------"
echo "Files Generated List:"
ls -l $TARGET_DIR
echo "---------------------"
echo "Files Generated Content:"
cat ${TARGET_DIR}/*
echo "---------------------"