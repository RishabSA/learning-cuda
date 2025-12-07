#include <stdio.h>
#include <stdlib.h>

int main() {
    int arr[] = {12, 24, 36, 48, 60};

    // size_t is the size type for memory allocation
    // size_t is an unsigned integer data type used to represent the size of objects in bytes
    // size_t is guaranteed to be big enough to contain the size of the biggest object the host system can handle
    // size_t is a typedef for unsigned long (64 bits)
    int len = sizeof(arr) / sizeof(arr[0]);
    printf("Length of arr: %d\n", len);  // 5

    printf("size of size_t: %zu bytes \n", sizeof(size_t));  // 8 bytes -> 64 bits which is memory safe
    printf("size of int: %zu bytes\n", sizeof(int));  // 4 bytes -> 32 bits
    
    return 0;
}