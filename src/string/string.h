#ifndef string_h
#define string_h

#include <stdbool.h>

int strlen(const char* ptr);
bool isdigit(char c);
int todigit(char c);
int strnlen(const char* str, int max);

#endif