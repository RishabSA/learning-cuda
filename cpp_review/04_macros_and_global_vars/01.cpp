#include <stdio.h>

// Examples of each conditional macro
// #if
// #ifdef
// #ifndef
// #elif
// #else
// #endif

#define PI 3.14159
#define AREA(r) (PI * r * r)

// If radius is not defined, default it to 7
#ifndef radius
#define radius 7
#endif

// Clamps the value of radius between 5 and 10. If it is already between 5 and 10, set it to 7
// We can only use integer constants in #if and #elif
#if radius > 10
#define radius 10
#elif radius < 5
#define radius 5
#else
#define radius 7
#endif


int main() {
    printf("Area of circle with radius %d: %f\n", radius, AREA(radius));  // Area of circle with radius 6.900000: 153.937910

    return 0;
}