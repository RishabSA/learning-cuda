#include <stdio.h>
#include <stdlib.h>

int main() {
    // Initialize the pointer to NULL
    int* ptr = NULL;
    printf("Initial ptr value: %p\n", (void*)ptr);

    // Check for NULL before using
    if (ptr == NULL) {
        printf("ptr is NULL, cannot dereference\n");
    }

    // Allocate memory
    ptr = (int*) malloc(sizeof(int)); // malloc returns void*
    if (ptr == NULL) {
        printf("Memory allocation failed");
        return 1;
    }

    printf("After allocation, ptr value: %p\n", (void*)ptr);

    // It is safe to use ptr after NULL check
    *ptr = 42;
    printf("Value at ptr: %d\n", *ptr);

    // Clean up
    free(ptr);
    ptr = NULL;  // Set to NULL after freeing

    printf("After free, ptr value: %p\n", (void*)ptr);

    // Demonstrate safety of NULL check after free
    if (ptr == NULL) {
        printf("ptr is NULL, safely avoided use after free\n");
    }

    return 0;
}