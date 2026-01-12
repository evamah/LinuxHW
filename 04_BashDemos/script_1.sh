#!/bin/bash

while true; do
  echo "1) List files"
  echo "2) Show disk"
  echo "3) Exit"
  read -p "Choose: " c

  case $c in
     1) ls -la ;;
     2) df -h ;;
     3) exit 0 ;;
     *) echo "Invalid!" ;;
  esac
done