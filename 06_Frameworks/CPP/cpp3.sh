#!/bin/bash

rm -rf APP03
mkdir APP03
cd APP03

# Reusing the simple math example for clarity
cp ../APP01/*.cpp ../APP01/*.h .

echo ">> Compiling app3:"
# -c means "compile only, don't make an executable"
g++ -c mymath.cpp -o mymath.o
g++ -c main.cpp -o main.o
g++ main.o mymath.o -o app3

echo ">> running app3:"
./app3
cd ..

echo "=========================================================="
echo "Done."