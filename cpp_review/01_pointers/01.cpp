#include <stdio.h>

int main () {
    int x = 10;

    // & "address of" operator
    // * "dereference" operator
    int* ptr = &x; // & is used to get the memory address of the variable x

    printf("Address of x: %p\n", ptr); // memory address of x

    // Get the value stored at the the memory address stored in ptr (dereferencing)
    printf("Value of x: %d\n", *ptr); // 10
    
    return 0;
}