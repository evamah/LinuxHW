if [ $# -ne 3 ]; then
 echo "Usage: $0 folder find replace"
 exit 1
fi

# dir to search
DIR=$1
# find text in all files 
FIND=$2
#replace text to new text
REPL=$3

# iterate all text files in $DIR
for file in "$DIR"/*.txt; do
#replace all (/g like in global)
   sed -i "s/$FIND/$REPL/g" "$file"
done
