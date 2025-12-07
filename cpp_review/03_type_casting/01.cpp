#include <stdio.h>

int main() {
    float f = 69.69;
    int i = (int) f;

    printf("%d\n", i);  // 69 (always rounds to integer)

    char c = (char) i;
    printf("%c\n", c);  // E (ASCII value of 69)
}