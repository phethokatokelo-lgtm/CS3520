#include <iostream>

// Procedure using Euclid's algorithm
int gcd(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

int main() {
    int x = 48;
    int y = 18;
    int result = gcd(x, y);
    std::cout << "GCD: " << result << std::endl;
    return 0;
}
