#!/bin/bash

# Loop through all arguments provided
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n)
      NAME="$2"   # Store the value next to -n
      shift 2     # Skip over '-n' and 'Alice'
      ;;
    -a|--age)
      AGE="$2"    # Store the value next to -a
      shift 2     # Skip over '-a' and '25'
      ;;
    *)
      echo "Unknown flag: $1"
      shift 1
      ;;
  esac
done

# Print the result
echo "Hello, $NAME. You are $AGE years old."