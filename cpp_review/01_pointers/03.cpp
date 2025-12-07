#include <stdio.h>

int main() {
    int num = 10;
    float fnum = 3.14;
    void* vptr;

    // Void pointers are used when we don't know the data type of the memory address

    vptr = &num; // vptr is a memory address "&num" but it is stored as a void pointer (no data type)
    
    // Void pointers cannot be dereferenced, so we cast it to an integer pointer to store the integer value at that memory address "(int*)vptr"
    // Then, we dereference it with * to get the value "*((int*)vptr)"
    printf("Integer: %d\n", *(int*)vptr); // 10

    vptr = &fnum;
    printf("Float: %.2f\n", *(float*)vptr); // 3.14
}