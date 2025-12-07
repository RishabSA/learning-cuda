#include <stdio.h>

int main() {
    int arr[] = {12, 24, 36, 48, 60};

    int* ptr = arr;  // ptr points to the first element of arr

    printf("Position 0: %d\t%p\n\n", *ptr, ptr);  // 12

    // The pointer is incremented by 4 bytes (size of int = 4 bytes * 8 bits/bytes = 32 bits = int32) each timeå
    // arrays are layed out in memory in a contiguous manner (one after the other)
    for (int i = 0; i < 5; i++) {
        printf("%d\t", *ptr); // value
        printf("%p\t", ptr); // memory address of value
        printf("%p\n", &ptr); // memory address of pointer
        ptr++;
    }
}