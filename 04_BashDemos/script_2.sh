#!/bin/bash

PACKAGE=$1

if [ -z "$PACKAGE" ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

echo "Checking if '$PACKAGE' is installed..."

if dpkg -s "$PACKAGE" >/dev/null 2>&1; then
    echo "Package '$PACKAGE' is already installed."
else
    echo "Package '$PACKAGE' is NOT installed. Installing..."
    sudo apt update && sudo apt install -y "$PACKAGE"
fi
