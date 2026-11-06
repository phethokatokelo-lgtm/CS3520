#include <iostream>

int main() {
    int arr[] = {2, 7, 10, 15, 22, 33, 40};
    int size = sizeof(arr) / sizeof(arr[0]);
    int count = 0;

    for (int i = 0; i < size; ++i) {
        // Bit test: if lowest bit is 0, it's even
        if ((arr[i] & 1) == 0) {
            count++;
        }
    }

    std::cout << "Even count: " << count << std::endl;
    return 0;
}
