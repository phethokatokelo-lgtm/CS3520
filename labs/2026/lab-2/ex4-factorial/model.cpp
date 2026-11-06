#include <iostream>

// Procedure (Function)
int factorial(int n) {
    int result = 1;
    for (int i = 1; i <= n; ++i) {
        result *= i;
    }
    return result;
}

int main() {
    int N = 5;
    int fact = factorial(N);
    std::cout << "Factorial: " << fact << std::endl;
    return 0;
}
