#include "string.h"

int strlen(const char* str)
{
    int len = 0;
    while (str[len] != 0)
        len++;
    
    return len;
}

bool isdigit(char c)
{
    return c >= 48 && c <= 57;
}

int todigit(char c)
{
    return c - 48;
}

int strnlen(const char* str, int max)
{
    int len = 0;
    while (str[len] != 0 && len < max)
        len++;
    
    return len;
}