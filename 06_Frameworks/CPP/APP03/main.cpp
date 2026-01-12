#include <iostream>
#include "mymath.h" // We reference the header to know 'add' exists

int main() {
    std::cout << "2 + 5 = " << add(2, 5) << std::endl;
    return 0;
}
