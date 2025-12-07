#include <stdio.h>

typedef struct {
    float x;
    float y;
} Point;

int main() {
    Point p = {1.1, 2.5};
    printf("size of Point: %zu bytes\n", sizeof(Point));  // 8 bytes (4 bytes (float x) + 4 bytes (float y))
    
}