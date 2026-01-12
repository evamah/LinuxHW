#include <iostream>
int main() {
    int num;
    while(std::cin >> num) {
        if(num % 2 == 0) {
            std::cout << num << std::endl;
        }
    }
    return 0;
}
