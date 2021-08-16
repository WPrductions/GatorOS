#include "pparser.h"

#include "config.h"
#include "memory/heap/kheap.h"
#include "memory/memory.h"
#include "string/string.h"
#include "status.h"

static int pathparser_path_valid_format(const char* path)
{
    int len = strnlen(path, GATOROS_MAX_PATH);
    return (len >= 3 && isdigit(path[0]) && (memcmp((void*) &path[1], ":/", 2) == 0));
}

static int pathparser_get_drive_by_path(const char** path)
{
    if(!pathparser_path_valid_format(*path))
        return -EBADPATH;

    int drive_n = todigit(*path[0]);

    // Add 3 bytes to skip number 0:/ 1:/ 2:/ e.g. 0:/test.txt -> test.txt
    *path += 3;

    return drive_n;
}

static struct path_root* pathparser_create_root(int drive_n)
{
    struct path_root* root = kzalloc(sizeof(struct path_root));
    root->drive_nu = drive_n;
    root->first = 0;
    return root;
}

static const char* pathparser_get_path_part(const char** path)
{
    char* path_part = kzalloc(GATOROS_MAX_PATH);
    int i = 0;
    while(**path != '/' && **path != 0x00)
    {
        path_part[i] = **path;
        *path += 1;
        i++;
    }

    if(**path == '/')
        *path += 1;

    if(i == 0)
    {
        kfree(path_part);
        path_part = 0;
    }

    return path_part;
}

struct path_part* pathparser_parse_path_part(struct path_part* last,const char** path)
{
    const char* path_part_str = pathparser_get_path_part(path);
    if(!path_part_str)
        return 0;

    struct path_part* part = kzalloc(sizeof(struct path_part));
    part->part = path_part_str;
    part->next = 0x00;

    if(last)
    {
        last->next = part;
    }

    return part;
}

struct path_root* pathparser_parse(const char* path, const char* current_dir_path)
{
    int res = 0;
    const char* temp_path = path;
    struct path_root* path_root = 0;

    if(strlen(path) > GATOROS_MAX_PATH)
        goto out;

    res = pathparser_get_drive_by_path(&temp_path);
    if (res < 0)
        goto out;

    path_root = pathparser_create_root(res);
    if(!path_root)
        goto out;

    struct path_part* first_part = pathparser_parse_path_part(NULL, &temp_path);
    if(!first_part)
        goto out;
    
    path_root->first = first_part;

    struct path_part* part = pathparser_parse_path_part(first_part, &temp_path);
    while (part)
    {
        part = pathparser_parse_path_part(part, &temp_path);
    }
    
out:
    return path_root;
}

void pathparser_free(struct path_root* root)
{
    struct path_part* part = root->first;
    while(part)
    {
        struct path_part* next_part = part->next;
        kfree((void*) part->part);
        kfree(part);
        part = next_part;
    }
    kfree(root);
}