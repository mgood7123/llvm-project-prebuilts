#include <iostream>
#include <iosfwd>
#include <stdio.h>
#define STR(x) #x
int main() {
    printf("_GLIBCXX_RELEASE = %s\n", STR(_GLIBCXX_RELEASE));
    return 0;
}
