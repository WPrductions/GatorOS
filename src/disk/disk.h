#ifndef DISK_H
#define DISK_H

typedef unsigned int GATOROS_DISK_TYPE;

// Reprisents a real pysical hard disk
#define GATOROS_DISK_TYPE_REAL 0


struct disk
{
    GATOROS_DISK_TYPE type;
    int sector_size;
};


void disk_search_and_init();
struct disk* disk_get(int index);
int disk_read_block(struct disk* idisk, int lba, int total, void* buffer);


#endif