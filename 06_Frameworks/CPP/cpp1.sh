#!/bin/bash

# Clean previous runs
rm -rf APP01
mkdir -p APP01
cd APP01

# 1. The Header (Declaration)
cat << 'EOF' > mymath.h
#ifndef MYMATH_H
#define MYMATH_H

// Just the signature. No code logic here.
int add(int a, int b);

#endif
EOF

# 2. The Implementation (Definition)
cat << 'EOF' > mymath.cpp
#include "mymath.h"

// The actual logic
int add(int a, int b) {
    return a + b;
}
EOF

# 3. The Main Program
cat << 'EOF' > main.cpp
#include <iostream>
#include "mymath.h" // We reference the header to know 'add' exists

int main() {
    std::cout << "2 + 5 = " << add(2, 5) << std::endl;
    return 0;
}
EOF

echo ">> compile app1:"
g++ main.cpp mymath.cpp -o app1

echo ">> Running app1:"
./app1
cd ..